package com.ignium.nganya.schedule;

import com.ignium.nganya.route.models.RouteAssignment;
import com.ignium.nganya.route.models.VehicleAssignment;
import jakarta.annotation.Resource;
import jakarta.ejb.Stateless;
import java.io.Serializable;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.sql.Date;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.sql.DataSource;

/**
 * Data access object for vehicle scheduling operations
 * @author olal
 */
@Stateless
public class ScheduleDao implements Serializable {
    @Resource(lookup = "java:global/nganya1") 
    private DataSource dataSource;
    private static final Logger logger = Logger.getLogger(ScheduleDao.class.getName());

    public String getCurrentRoute(String username) {
        String sql = """
            SELECT r.name
            FROM route_assignments ra
            JOIN routes r ON r.id = ra.route_id
            JOIN users u ON u.id = ra.driver_id
            WHERE u.username = ? 
            AND ra.assignment_date = CURRENT_DATE
            AND ra.status = 'scheduled'
            """;
        
        try (var conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("name");
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting current route", ex);
        }
        return null;
    }

    public double getHoursWorkedToday(String username) {
        String sql = "SELECT COALESCE(EXTRACT(EPOCH FROM SUM(end_time - start_time))/3600, 0) as hours FROM trips WHERE driver_username = ? AND DATE(start_time) = CURRENT_DATE AND end_time IS NOT NULL";
        try (var conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("hours");
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error calculating hours worked", ex);
        }
        return 0.0;
    }


    
    /**
     * Load all vehicle assignments
     * @return List of assignments
     */
    public List<Assignment> loadAssignments() {
        List<Assignment> assignments = new ArrayList<>();
        String sql = "SELECT a.id, d.first_name, d.second_name, v.plate_number, v.vehicle_model, a.start_date, a.end_date, a.status "
                + "FROM vehicle_assignments a "
                + "JOIN users d ON a.driver_id = d.id "
                + "JOIN vehicle v ON a.vehicle_id = v.id "
                + "ORDER BY a.start_date DESC";
        try (var conn = dataSource.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                assignments.add(new Assignment(
                        rs.getInt("id"),
                        rs.getString("first_name") + " " + rs.getString("second_name"),
                        rs.getString("plate_number"),
                        rs.getString("vehicle_model"),
                        rs.getDate("start_date"),
                        rs.getDate("end_date"),
                        rs.getString("status")
                ));
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error loading assignments", ex);
        }
        return assignments;
    }
    
    /**
     * Assign a vehicle to a driver
     * @param driverId The driver ID
     * @param vehicleId The vehicle ID
     * @param startDate Start date of assignment
     * @param endDate End date of assignment
     */
    public void assignVehicle(int driverId, int vehicleId, Date startDate, Date endDate) {
        String sql = "INSERT INTO vehicle_assignments (driver_id, vehicle_id, start_date, end_date, status) "
                + "VALUES (?, ?, ?, ?, 'active')";
        try (var conn = dataSource.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, driverId);
            stmt.setInt(2, vehicleId);
            stmt.setDate(3, new java.sql.Date(startDate.getTime()));
            stmt.setDate(4, new java.sql.Date(endDate.getTime()));
            stmt.executeUpdate();
            logger.info("Vehicle assigned successfully: Driver ID " + driverId + ", Vehicle ID " + vehicleId);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error assigning vehicle", e);
        }
    }
    
    /**
     * Set assignment status to unassigned
     * @param assignmentId The assignment ID to unassign
     */
    public boolean unassignVehicle(int assignmentId) {
        String sql = "UPDATE vehicle_assignments SET status = 'cancelled' WHERE id = ?";
        try (var conn = dataSource.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, assignmentId);
            return stmt.executeUpdate() > 0 ;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error unassigning vehicle", e);
        }
        return false;
    }
    /**
 * Get active vehicle assignments that overlap any date 
 * between weekStart and weekEnd (inclusive).
 *
 * @param weekStart The first day of the week to schedule (e.g. 2025-06-08)
 * @param weekEnd   The last day of the week to schedule (e.g. 2025-06-14)
 * @return List of VehicleAssignment objects whose date‐range overlaps [weekStart … weekEnd]
 */
public List<VehicleAssignment> getActiveAssignments(LocalDate weekStart, LocalDate weekEnd) {
    List<VehicleAssignment> activeAssignments = new ArrayList<>();

    String sql = 
        "SELECT id, vehicle_id, driver_id, start_date, end_date, status " +
        "  FROM vehicle_assignments " +
        " WHERE status = 'active' " +
        "   AND start_date <= ? " +  // must start on or before weekEnd
        "   AND end_date   >= ?";    // must end on or after weekStart

    try (var conn = dataSource.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setDate(1, java.sql.Date.valueOf(weekEnd));
        stmt.setDate(2, java.sql.Date.valueOf(weekStart));

        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                VehicleAssignment assignment = new VehicleAssignment();
                assignment.setId(rs.getInt("id"));
                assignment.setVehicleId(rs.getInt("vehicle_id"));
                assignment.setDriverId(rs.getInt("driver_id"));
                assignment.setStartDate(rs.getDate("start_date"));
                assignment.setEndDate(rs.getDate("end_date"));
                assignment.setStatus(rs.getString("status"));

                // Optional: if someone stored start_date > end_date, skip or log a warning
                LocalDate as = rs.getDate("start_date").toLocalDate();
                LocalDate ae = rs.getDate("end_date").toLocalDate();
                if (ae.isBefore(as)) {
                    logger.warning("Skipping assignment " + assignment.getId()
                        + " because startDate=" + as + " is after endDate=" + ae);
                    continue;
                }

                activeAssignments.add(assignment);
            }
        }
    } catch (SQLException ex) {
        logger.log(Level.SEVERE, "Error retrieving active assignments", ex);
    }

    return activeAssignments;
}

    
    /**
     * Creates SQL for the route_assignments table if it doesn't exist
     */
    public void createRouteAssignmentsTableIfNotExists() {
        String sql = "CREATE TABLE IF NOT EXISTS route_assignments ("
                + "id SERIAL PRIMARY KEY, "
                + "vehicle_id INTEGER NOT NULL, "
                + "driver_id INTEGER NOT NULL, "
                + "route_id INTEGER NOT NULL, "
                + "assignment_date DATE NOT NULL, "
                + "status VARCHAR(20) NOT NULL DEFAULT 'scheduled', "
                + "created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), "
                + "CONSTRAINT unique_vehicle_date UNIQUE (vehicle_id, assignment_date), "
                + "CONSTRAINT route_assignments_status_check CHECK (status IN ('scheduled', 'completed', 'cancelled')))";
        
        try (var conn = dataSource.getConnection(); 
             Statement stmt = conn.createStatement()) {
            
            stmt.executeUpdate(sql);
            
            // Create indexes
            stmt.executeUpdate("CREATE INDEX IF NOT EXISTS idx_route_assignments_date ON route_assignments(assignment_date)");
            stmt.executeUpdate("CREATE INDEX IF NOT EXISTS idx_route_assignments_status ON route_assignments(status)");
            
            logger.info("Route assignments table created or verified");
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error creating route_assignments table", ex);
        }
    }
    
    /**
     * Creates driver tracking tables if they don't exist
     */
    public void createDriverTrackingTablesIfNotExists() {
        try (var conn = dataSource.getConnection(); 
             Statement stmt = conn.createStatement()) {
            
            // Create driver_shifts table
            String driverShiftsSql = """
                CREATE TABLE IF NOT EXISTS driver_shifts (
                    id SERIAL PRIMARY KEY,
                    driver_username VARCHAR(50) NOT NULL,
                    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
                    end_time TIMESTAMP WITH TIME ZONE,
                    status VARCHAR(20) NOT NULL DEFAULT 'active',
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    CONSTRAINT driver_shifts_status_check CHECK (status IN ('active', 'completed', 'cancelled'))
                )
                """;
            stmt.executeUpdate(driverShiftsSql);
            
            // Create notifications table
            String notificationsSql = """
                CREATE TABLE IF NOT EXISTS notifications (
                    id SERIAL PRIMARY KEY,
                    driver_username VARCHAR(50) NOT NULL,
                    title VARCHAR(100) NOT NULL,
                    message TEXT NOT NULL,
                    icon VARCHAR(50),
                    color VARCHAR(50),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    read_at TIMESTAMP WITH TIME ZONE,
                    CONSTRAINT fk_notifications_driver 
                        FOREIGN KEY (driver_username) 
                        REFERENCES users(username)
                        ON DELETE CASCADE
                )
                """;
            stmt.executeUpdate(notificationsSql);
            
            // Create indexes
            stmt.executeUpdate("CREATE INDEX IF NOT EXISTS idx_notifications_username ON notifications(driver_username)");
            stmt.executeUpdate("CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at)");
            stmt.executeUpdate("CREATE INDEX IF NOT EXISTS idx_notifications_read_at ON notifications(read_at)");
            
            logger.info("Driver tracking and notifications tables created or verified");
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error creating driver tracking tables", ex);
        }
    }
    
    /**
     * Save a route assignment
     * @param vehicleId Vehicle ID
     * @param driverId Driver ID
     * @param routeId Route ID
     * @param assignmentDate Date of assignment
     * @param status Status of assignment
     * @return ID of the saved assignment
     */
    public int saveRouteAssignment(int vehicleId, int driverId, int routeId, LocalDate assignmentDate, String status) {
        String sql = "INSERT INTO route_assignments (vehicle_id, driver_id, route_id, assignment_date, status) "
                + "VALUES (?, ?, ?, ?, ?) "
                + "ON CONFLICT (vehicle_id, assignment_date) DO UPDATE "
                + "SET driver_id = EXCLUDED.driver_id, route_id = EXCLUDED.route_id, status = EXCLUDED.status "
                + "RETURNING id";
        
        try (var conn = dataSource.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, vehicleId);
            stmt.setInt(2, driverId);
            stmt.setInt(3, routeId);
            stmt.setDate(4, java.sql.Date.valueOf(assignmentDate));
            stmt.setString(5, status);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int id = rs.getInt("id");
                    logger.info("Route assignment saved with ID: " + id);
                    return id;
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error saving route assignment", ex);
        }
        
        return -1;
    }
    
    /**
     * Check if a vehicle is already assigned to a route on a specific date
     * @param vehicleId Vehicle ID
     * @param date Date to check
     * @return true if vehicle is already assigned, false otherwise
     */
    public boolean isVehicleAssignedOnDate(int vehicleId, LocalDate date) {
        String sql = "SELECT COUNT(*) FROM route_assignments "
                + "WHERE vehicle_id = ? AND assignment_date = ? AND status != 'cancelled'";
        
        try (var conn = dataSource.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, vehicleId);
            stmt.setDate(2, java.sql.Date.valueOf(date));
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error checking vehicle assignment", ex);
        }
        
        return false;
    }
    
    /**
     * Get all route assignments for a specific date range
     * @param startDate Start of date range
     * @param endDate End of date range
     * @return List of RouteAssignment objects
     */
    public List<RouteAssignment> getRouteAssignments(LocalDate startDate, LocalDate endDate) {
        List<RouteAssignment> assignments = new ArrayList<>();
        String sql = "SELECT ra.id, ra.vehicle_id, ra.driver_id, ra.route_id, ra.assignment_date, "
                + "ra.status, r.name as route_name, u.first_name, u.second_name, v.plate_number "
                + "FROM route_assignments ra "
                + "JOIN routes r ON ra.route_id = r.id "
                + "JOIN users u ON ra.driver_id = u.id "
                + "JOIN vehicle v ON ra.vehicle_id = v.id "
                + "WHERE ra.assignment_date BETWEEN ? AND ? "
                + "ORDER BY ra.assignment_date, ra.route_id";
        
        try (var conn = dataSource.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setDate(1, java.sql.Date.valueOf(startDate));
            stmt.setDate(2, java.sql.Date.valueOf(endDate));
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    RouteAssignment assignment = new RouteAssignment();
                    assignment.setId(rs.getInt("id"));
                    assignment.setVehicleId(rs.getInt("vehicle_id"));
                    assignment.setDriverId(rs.getInt("driver_id"));
                    assignment.setRouteId(rs.getInt("route_id"));
                    assignment.setAssignmentDate(rs.getDate("assignment_date").toLocalDate());
                    assignment.setStatus(rs.getString("status"));
                    assignment.setRouteName(rs.getString("route_name"));
                    assignment.setDriverName(rs.getString("first_name") + " " + rs.getString("second_name"));
                    assignment.setVehiclePlate(rs.getString("plate_number"));
                    
                    assignments.add(assignment);
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error retrieving route assignments", ex);
        }
        
        return assignments;
    }
    
    /**
     * Retrieve the latest active vehicle assignment for a given driver.
     *
     * @param driverId the ID of the driver
     * @return the latest active VehicleAssignment, or null if none found
     */
    public Assignment findActiveDriverAssignments(int driverId) {
        String sql = """
        SELECT a.id, a.vehicle_id, a.driver_id, a.start_date, a.end_date, a.status, v.plate_number, v.vehicle_model
          FROM vehicle_assignments a
          JOIN vehicle v ON a.vehicle_id = v.id           
         WHERE a.driver_id = ?
           AND a.status = 'active'
         ORDER BY a.start_date DESC
         LIMIT 1
    """;

    
        try (var conn = dataSource.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            // Set the driver ID parameter
            stmt.setInt(1, driverId);  

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Assignment va  = new Assignment(
                        rs.getInt("vehicle_id"),
                        rs.getString("driver_id"),
                        rs.getString("plate_number"),
                        rs.getString("vehicle_model"),
                        rs.getDate("start_date"),
                        rs.getDate("end_date"),
                        rs.getString("status")
                );
                    return va;
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error retrieving latest active assignment for driver " + driverId, ex);
        }
        return null;
    }
    
    public Assignment findAssignment(int driverId) {
        String sql = """
        SELECT a.id, a.vehicle_id, a.driver_id, a.start_date, a.end_date, a.status, v.plate_number, v.vehicle_model
          FROM vehicle_assignments a
          JOIN vehicle v ON a.vehicle_id = v.id           
         WHERE a.driver_id = ?
           AND a.status = 'active'
         ORDER BY a.start_date DESC
         LIMIT 1
    """;

    
        try (var conn = dataSource.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            // Set the driver ID parameter
            stmt.setInt(1, driverId);  

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Assignment va  = new Assignment(
                        rs.getInt("vehicle_id"),
                        rs.getString("driver_id"),
                        rs.getString("plate_number"),
                        rs.getString("vehicle_model"),
                        rs.getDate("start_date"),
                        rs.getDate("end_date"),
                        rs.getString("status"),
                        rs.getInt("vehicle_id")
                );
                   
                    return va;
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error retrieving latest active assignment for driver " + driverId, ex);
        }
        return null;
    }

    /**
     * Checks if the expired assignments trigger exists in the database
     * @return true if the trigger exists, false otherwise
     */
    private boolean triggerExists() {
        String sql = """
            SELECT EXISTS (
                SELECT 1 
                FROM pg_trigger 
                WHERE tgname = 'check_expired_assignments'
            );
            """;
        
        try (var conn = dataSource.getConnection(); 
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                return rs.getBoolean(1);
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error checking if trigger exists", ex);
        }
        return false;
    }

    /**
     * Creates a database trigger to automatically update expired assignments
     * @deprecated This method is deprecated as it causes stack depth issues. 
     * Use updateExpiredAssignments() instead.
     */
    @Deprecated
    public void createExpiredAssignmentsTrigger() {
        // First check if trigger exists
        if (!triggerExists()) {
            logger.info("No expired assignments trigger found");
            return;
        }

        // Remove trigger and function with CASCADE to ensure complete removal
        String dropTriggerSql = """
            DROP TRIGGER IF EXISTS check_expired_assignments ON vehicle_assignments CASCADE;
            DROP FUNCTION IF EXISTS update_expired_assignments() CASCADE;
            """;
        
        try (var conn = dataSource.getConnection(); 
             Statement stmt = conn.createStatement()) {
            
            stmt.execute(dropTriggerSql);
            
            // Verify trigger was removed
            if (!triggerExists()) {
                logger.info("Successfully removed expired assignments trigger");
            } else {
                logger.warning("Failed to remove expired assignments trigger");
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error removing expired assignments trigger", ex);
        }
    }

    /**
     * Updates the status of expired vehicle assignments to 'completed'
     * This method should be called by a scheduled task
     */
    public void updateExpiredAssignments() {
        // First ensure trigger is removed
        createExpiredAssignmentsTrigger();

        String sql = """
            WITH expired_assignments AS (
                SELECT id 
                FROM vehicle_assignments 
            WHERE status = 'active' 
            AND end_date < CURRENT_DATE
                FOR UPDATE SKIP LOCKED
            )
            UPDATE vehicle_assignments va
            SET status = 'completed'
            FROM expired_assignments ea
            WHERE va.id = ea.id
            """;
        
        try (var conn = dataSource.getConnection(); 
             Statement stmt = conn.createStatement()) {
            
            int updated = stmt.executeUpdate(sql);
            if (updated > 0) {
                logger.info("Updated " + updated + " expired vehicle assignments to completed status");
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error updating expired assignments", ex);
        }
    }

    /**
     * Checks if a vehicle has any overlapping assignments in the given date range
     * @param vehicleId The vehicle ID to check
     * @param startDate Start date of the proposed assignment
     * @param endDate End date of the proposed assignment
     * @return true if there are overlapping assignments, false otherwise
     */
    public boolean hasOverlappingAssignments(int vehicleId, Date startDate, Date endDate) {
        String sql = """
            SELECT COUNT(*) 
            FROM vehicle_assignments 
            WHERE vehicle_id = ? 
            AND status = 'active'
            AND (
                (start_date <= ? AND end_date >= ?) OR  -- New assignment starts during existing
                (start_date <= ? AND end_date >= ?) OR  -- New assignment ends during existing
                (start_date >= ? AND end_date <= ?)     -- New assignment is completely within existing
            )
            """;
        
        try (var conn = dataSource.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, vehicleId);
            stmt.setDate(2, new java.sql.Date(endDate.getTime()));    // For first overlap check
            stmt.setDate(3, new java.sql.Date(startDate.getTime()));
            stmt.setDate(4, new java.sql.Date(endDate.getTime()));    // For second overlap check
            stmt.setDate(5, new java.sql.Date(endDate.getTime()));
            stmt.setDate(6, new java.sql.Date(startDate.getTime()));  // For third overlap check
            stmt.setDate(7, new java.sql.Date(endDate.getTime()));
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error checking for overlapping assignments", ex);
        }
        return false;
    }

    /**
     * Checks if a driver has any overlapping assignments in the given date range
     * @param driverId The driver ID to check
     * @param startDate Start date of the proposed assignment
     * @param endDate End date of the proposed assignment
     * @return true if there are overlapping assignments, false otherwise
     */
    public boolean hasOverlappingDriverAssignments(int driverId, Date startDate, Date endDate) {
        String sql = """
            SELECT COUNT(*) 
            FROM vehicle_assignments 
            WHERE driver_id = ? 
            AND status = 'active'
            AND (
                (start_date <= ? AND end_date >= ?) OR  -- New assignment starts during existing
                (start_date <= ? AND end_date >= ?) OR  -- New assignment ends during existing
                (start_date >= ? AND end_date <= ?)     -- New assignment is completely within existing
            )
            """;
        
        try (var conn = dataSource.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, driverId);
            stmt.setDate(2, new java.sql.Date(endDate.getTime()));    // For first overlap check
            stmt.setDate(3, new java.sql.Date(startDate.getTime()));
            stmt.setDate(4, new java.sql.Date(endDate.getTime()));    // For second overlap check
            stmt.setDate(5, new java.sql.Date(endDate.getTime()));
            stmt.setDate(6, new java.sql.Date(startDate.getTime()));  // For third overlap check
            stmt.setDate(7, new java.sql.Date(endDate.getTime()));
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error checking for overlapping driver assignments", ex);
        }
        return false;
    }
}
