package com.ignium.nganya.fleet;

import jakarta.annotation.Resource;
import jakarta.enterprise.context.RequestScoped;
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

@RequestScoped
public class BusDao implements BusDaoApi {

    private static final Logger logger = Logger.getLogger(BusDao.class.getName());

    @Resource(lookup = "java:global/nganya1")
    private DataSource dataSource;

    @Override
    public boolean save(Vehicle vehicle) {
        String sql = "INSERT INTO vehicle (plate_number, vehicle_model, owner_national_id, capacity, sacco) VALUES (?, ?, ?, ?, ?)";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, vehicle.getPlateNumber());
            ps.setString(2, vehicle.getVehicleModel());
            ps.setString(3, vehicle.getOwnerNationalId());
            ps.setInt(4, vehicle.getCapacity());
            ps.setString(5, vehicle.getSacco());

            return ps.executeUpdate() > 0;

        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error saving vehicle", ex);
            return false;
        }
    }

    @Override
    public Vehicle findByPlateNumber(String plateNumber) {
        String sql = "SELECT id, plate_number, vehicle_model, owner_national_id, capacity, sacco, status FROM vehicle WHERE plate_number = ?";

        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, plateNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Vehicle vehicle = new Vehicle();
                    vehicle.setId(rs.getLong("id"));
                    vehicle.setPlateNumber(rs.getString("plate_number"));
                    vehicle.setVehicleModel(rs.getString("vehicle_model"));
                    vehicle.setOwnerNationalId(rs.getString("owner_national_id"));
                    vehicle.setCapacity(rs.getInt("capacity"));
                    vehicle.setSacco(rs.getString("sacco"));
                    vehicle.setStatus(rs.getString("status"));
                    return vehicle;
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error finding vehicle by plate number", ex);
        }
        return null;
    }

    @Override
    public List<Vehicle> findAll(int offset, int pageSize) {
        List<Vehicle> vehicles = new ArrayList<>();
        String sql = "SELECT id, plate_number, vehicle_model, owner_national_id, capacity, sacco, status FROM vehicle ORDER BY id DESC LIMIT ? OFFSET ?";

        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, pageSize);
            ps.setInt(2, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Vehicle vehicle = new Vehicle();
                    vehicle.setId(rs.getLong("id"));
                    vehicle.setPlateNumber(rs.getString("plate_number"));
                    vehicle.setVehicleModel(rs.getString("vehicle_model"));
                    vehicle.setOwnerNationalId(rs.getString("owner_national_id"));
                    vehicle.setCapacity(rs.getInt("capacity"));
                    vehicle.setSacco(rs.getString("sacco"));
                    vehicle.setStatus(rs.getString("status"));
                    vehicles.add(vehicle);
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error fetching all vehicles", ex);
        }
        return vehicles;
    }

    @Override
    public boolean update(Vehicle vehicle) {
        String sql = "UPDATE vehicle SET vehicle_model = ?, owner_national_id = ?, capacity = ?, sacco = ? WHERE plate_number = ?";

        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, vehicle.getVehicleModel());
            ps.setString(2, vehicle.getOwnerNationalId());
            ps.setInt(3, vehicle.getCapacity());
            ps.setString(4, vehicle.getSacco());
            ps.setString(5, vehicle.getPlateNumber());

            return ps.executeUpdate() > 0;

        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error updating vehicle", ex);
            return false;
        }
    }

    @Override
    public boolean delete(String plateNumber) {
        // Fixed typo: "vahicle" -> "vehicle"
        String sql = "DELETE FROM vehicle WHERE plate_number = ?";

        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, plateNumber);
            return ps.executeUpdate() > 0;

        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error deleting vehicle", ex);
            return false;
        }
    }

    public void vehicleStatus(String status, String plateNumber) {
        // Fixed typo: "staus" -> "status"
        String sql = "UPDATE vehicle SET status = ? WHERE plate_number = ?";

        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, plateNumber);
            ps.executeUpdate();

        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Unable to change the bus status for plate: " + plateNumber, ex);
        }
    }

    public List<Vehicle> availableVehicles() {
        String sql = "SELECT id, plate_number, vehicle_model, owner_national_id, capacity, sacco, status FROM vehicle WHERE status = ?";
        List<Vehicle> vehicles = new ArrayList<>();

        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "available");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Vehicle vehicle = new Vehicle();
                    vehicle.setId(rs.getLong("id"));
                    vehicle.setPlateNumber(rs.getString("plate_number"));
                    vehicle.setVehicleModel(rs.getString("vehicle_model"));
                    vehicle.setOwnerNationalId(rs.getString("owner_national_id"));
                    vehicle.setCapacity(rs.getInt("capacity"));
                    vehicle.setSacco(rs.getString("sacco"));
                    vehicle.setStatus(rs.getString("status"));
                    vehicles.add(vehicle);
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error fetching available vehicles", ex);
        }
        return vehicles;
    }

    @Override
    public int getVehicleFuelLevel(String plateNumber) {
        String sql = "SELECT fuel_level FROM vehicle_status WHERE plate_number = ?";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, plateNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("fuel_level");
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting fuel level", ex);
        }
        return 0;
    }

    @Override
    public int getVehicleHealth(String plateNumber) {
        String sql = "SELECT engine_health FROM vehicle_status WHERE plate_number = ?";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, plateNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("engine_health");
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting engine health", ex);
        }
        return 0;
    }

    @Override
    public String getAssignedVehicle(String username) {
        String sql = """
            SELECT v.plate_number 
            FROM vehicle_assignments va
            JOIN vehicle v ON v.id = va.vehicle_id
            JOIN users u ON u.id = va.driver_id
            WHERE u.username = ?
            AND va.status = 'active'
            AND CURRENT_DATE BETWEEN va.start_date AND va.end_date
            """;
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("plate_number");
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting assigned vehicle", ex);
        }
        return null;
    }

    public Map<String, Integer> fleetKpi() {
        Map<String, Integer> kpi = new HashMap<>();

        String sqlTotal = "SELECT COUNT(*) FROM vehicle";
        String sqlActive = "SELECT COUNT(*) FROM vehicle WHERE status = 'ACTIVE'";

        try (var conn = dataSource.getConnection(); Statement stmt = conn.createStatement()) {

            try (ResultSet rsTotal = stmt.executeQuery(sqlTotal)) {
                if (rsTotal.next()) {
                    int totalVehicles = rsTotal.getInt(1);
                    kpi.put("totalVehicles", totalVehicles);
                }
            }

            try (ResultSet rsActive = stmt.executeQuery(sqlActive)) {
                if (rsActive.next()) {
                    int activeVehicles = rsActive.getInt(1);
                    kpi.put("activeVehicles", activeVehicles);
                }
            }

        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error retrieving Fleet KPIs", ex);
        }
        return kpi;
    }

    public int getVehicleCapacityById(int vehicleId) {
        String sql = "SELECT capacity FROM vehicle WHERE id = ?";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("capacity");
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting vehicle capacity", ex);
        }
        return 0;
    }

    public Vehicle getVehicleById(Integer vehicleId) {
        String sql = "SELECT * FROM vehicle WHERE id = ?";

        try (var conn = dataSource.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, vehicleId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Vehicle vehicle = new Vehicle();
                    vehicle.setId(rs.getLong("id"));
                    vehicle.setPlateNumber(rs.getString("plate_number"));
                    vehicle.setVehicleModel(rs.getString("vehicle_model"));
                    vehicle.setOwnerNationalId(rs.getString("owner_national_id"));
                    vehicle.setCapacity(rs.getInt("capacity"));
                    vehicle.setSacco(rs.getString("sacco"));
                    vehicle.setStatus(rs.getString("status"));
                    return vehicle;
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error retrieving vehicle by ID", ex);
        }
        return null;
    }

    // Method to get total count for pagination
    public int getTotalVehicleCount() {
        String sql = "SELECT COUNT(*) FROM vehicle";
        try (var conn = dataSource.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting total vehicle count", ex);
        }
        return 0;
    }
}
