package com.ignium.nganya.driver;

import com.ignium.nganya.route.models.RouteAssignment;
import com.ignium.nganya.user.Role;
import com.ignium.nganya.websocket.LocationUpdate;
import jakarta.annotation.Resource;
import jakarta.enterprise.context.Dependent;
import jakarta.inject.Inject;
import jakarta.security.enterprise.identitystore.Pbkdf2PasswordHash;
import java.io.Serializable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.sql.DataSource;

@Dependent
public class DriverDao implements DriverDaoApi, Serializable {

    private static final Logger logger = Logger.getLogger(DriverDao.class.getName());

    @Resource(lookup = "java:global/nganya1") // Ensure JNDI matches your server settings
    private DataSource dataSource;

    @Inject
    private Pbkdf2PasswordHash passwordHasher;

    @Override
    public boolean saveDriver(Driver driver) {
        String sql = "INSERT INTO users (username, email, password, first_name, second_name, phone_number, role, driver_licence) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        boolean result = false;
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, driver.getUsername());
            ps.setString(2, driver.getEmail());
            var passwordHash = passwordHasher.generate(driver.getPassword().toCharArray());
            ps.setString(3, passwordHash);
            ps.setString(4, driver.getFirstName());
            ps.setString(5, driver.getSecondName());
            ps.setString(6, driver.getPhoneNumber());
            ps.setString(7, "DRIVER");
            ps.setString(8, driver.getDriverLicence());

            result = ps.executeUpdate() > 0;

            return result;
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error saving driver", ex);
        }
        return result;
    }

    @Override
    public Driver getDriverById(int driverId) {
        String sql = "SELECT * FROM users WHERE id = ?";
        Driver driver = null;

        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    driver = new Driver(
                            rs.getInt("id"),
                            rs.getString("username"),
                            rs.getString("first_name"),
                            rs.getString("second_name"),
                            rs.getString("password"),
                            rs.getString("email"),
                            Role.valueOf(rs.getString("role")),
                            rs.getString("phone_number"),
                            rs.getString("driver_licence"),
                            rs.getString("status")
                    );
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error retrieving driver by ID", ex);
        }

        return driver;
    }

    @Override
    public List<Driver> getAllDrivers(int offset, int pageSize) {
        List<Driver> drivers = new ArrayList<>();
        String sql = "SELECT id, username, first_name, second_name, email, role, phone_number, driver_licence, status "
                + "FROM users WHERE role = 'DRIVER' AND status != 'INACTIVE' ORDER BY id DESC LIMIT ? OFFSET ?";

        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pageSize);
            ps.setInt(2, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Driver driver = new Driver(
                            rs.getInt("id"),
                            rs.getString("username"),
                            rs.getString("first_name"),
                            rs.getString("second_name"),
                            rs.getString("email"),
                            Role.valueOf(rs.getString("role")),
                            rs.getString("phone_number"),
                            rs.getString("driver_licence"),
                            rs.getString("status")
                    );
                    drivers.add(driver);
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error fetching all drivers with pagination", ex);
        }

        return drivers;
    }

    @Override
    public boolean updateDriver(Driver driver) {
        String sql = "UPDATE users SET username = ?, email = ?, password = ?, first_name = ?, second_name = ?, phone_number = ?, role = ?, driver_licence = ?, status = ? WHERE id = ?";
        boolean result = false;
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, driver.getUsername());
            ps.setString(2, driver.getEmail());
            ps.setString(3, driver.getPassword());
            ps.setString(4, driver.getFirstName());
            ps.setString(5, driver.getSecondName());
            ps.setString(6, driver.getPhoneNumber());
            ps.setString(7, driver.getGroup().name());
            ps.setString(8, driver.getDriverLicence());
            ps.setString(9, driver.getStatus());
            ps.setInt(10, driver.getUserId());

            result = ps.executeUpdate() > 0;

            return result;
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error updating driver", ex);
        }
        return result;
    }

    @Override
    public boolean deleteDriver(int driverId) {
        String sql = "UPDATE users SET status = 'INACTIVE' WHERE id = ?";
        boolean result = false;
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            ps.executeUpdate();
            result = ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error setting driver status to inactive", ex);
        }

        return result;
    }

    public void logPosition(LocationUpdate update) {
        String sql = "INSERT INTO locations (driver_id, lat, lng, accuracy) "
                + "VALUES (?, ?, ?, ?)";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, update.getDriverId());
            ps.setDouble(2, update.getLat());
            ps.setDouble(3, update.getLng());
            ps.setDouble(4, update.getAccuracy());
            ps.executeUpdate();
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error setting driver status to inactive", ex);
        }
    }

    public List<Driver> availableDrivers() {

        List<Driver> drivers = new ArrayList<>();
        String sql = "SELECT id, username FROM users WHERE role = 'DRIVER'";

        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Driver driver = new Driver(
                            rs.getInt("id"),
                            rs.getString("username")
                    );

                    drivers.add(driver);
                }
            }

        } catch (SQLException e) {
        }

        return drivers;
    }

    @Override
    public Map<String, Integer> driverKpi() {
        Map<String, Integer> kpi = new HashMap<>();

        // SQL queries to count total and active employees
        String sqlTotal = "SELECT COUNT(*) FROM users WHERE role = 'DRIVER'";
        String sqlActive = "SELECT COUNT(*) FROM users WHERE role = 'DRIVER' AND status = 'ACTIVE'";

        try (var conn = dataSource.getConnection(); Statement stmt = conn.createStatement()) {

            // Execute query for total employees
            try (ResultSet rsTotal = stmt.executeQuery(sqlTotal)) {
                if (rsTotal.next()) {
                    int totalDrivers = rsTotal.getInt(1);
                    kpi.put("totalDrivers", totalDrivers);
                }
            }

            // Execute query for active employees
            try (ResultSet rsActive = stmt.executeQuery(sqlActive)) {
                if (rsActive.next()) {
                    int activeDrivers = rsActive.getInt(1);
                    kpi.put("activeDrivers", activeDrivers);
                }
            }

        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error retrieving Driver KPIs", ex);
        }

        return kpi;
    }

    @Override
    public Driver getDriverByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        Driver driver = null;

        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    driver = new Driver(
                            rs.getInt("id"),
                            rs.getString("username"),
                            rs.getString("first_name"),
                            rs.getString("second_name"),
                            rs.getString("email"),
                            Role.valueOf(rs.getString("role")),
                            rs.getString("phone_number"),
                            rs.getString("driver_licence"),
                            rs.getString("status")
                    );
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error retrieving driver by ID", ex);
        }

        return driver;
    }

    public boolean updateDriverStatus(String username, String newStatus) {
        String sql = "UPDATE users SET status = ? WHERE username = ? AND role = 'DRIVER'";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, username);
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error updating driver status", ex);
            return false;
        }
    }

    public int getTotalDriverCount() {
        String sql = "SELECT COUNT(*) FROM users where role = 'DRIVER'";
        try (var conn = dataSource.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting total driver count", ex);
        }
        return 0;
    }

    public RouteAssignment getClosestActiveAssignment(String username) {
        String sql = """
    SELECT ra.id, ra.vehicle_id, ra.driver_id, ra.route_id, ra.assignment_date, ra.status,
               r.name as route_name, d.first_name, d.second_name, v.plate_number as vehicle_plate
        FROM route_assignments ra
        JOIN routes r ON r.id = ra.route_id
        JOIN users d ON d.id = ra.driver_id
        JOIN vehicle v ON v.id = ra.vehicle_id
        WHERE d.username = ? AND ra.assignment_date >= CURRENT_DATE
        ORDER BY ra.assignment_date ASC
        LIMIT 1
        """;

        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RouteAssignment assignment = new RouteAssignment();
                    assignment.setId(rs.getInt("id"));
                    assignment.setVehicleId(rs.getInt("vehicle_id"));
                    assignment.setDriverId(rs.getInt("driver_id"));
                    assignment.setRouteId(rs.getInt("route_id"));
                    assignment.setAssignmentDate(rs.getDate("assignment_date").toLocalDate());
                    assignment.setStatus(rs.getString("status"));
                    assignment.setRouteName(rs.getString("route_name"));
                    assignment.setDriverName(rs.getString("first_name") + " " + rs.getString("second_name"));
                    assignment.setVehiclePlate(rs.getString("vehicle_plate"));
                    return assignment;
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }

        return null; // No assignment found
    }
}
