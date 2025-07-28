package com.ignium.nganya.fleet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.annotation.Resource;
import jakarta.enterprise.context.RequestScoped;

@RequestScoped
public class MaintenanceDao {

    private static final Logger logger = Logger.getLogger(MaintenanceDao.class.getName());

    @Resource(lookup = "java:global/nganya1")
    private DataSource dataSource;

    public void insertMaintenance(Maintenance maintenance) throws SQLException {
        String sql = "INSERT INTO Maintenance (vehicleId, maintenanceDate, maintenanceType, description, cost, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, maintenance.getVehicleId());
            stmt.setObject(2, maintenance.getMaintenanceDate());
            stmt.setString(3, maintenance.getMaintenanceType());
            stmt.setString(4, maintenance.getDescription());
            stmt.setDouble(5, maintenance.getCost());
            stmt.setString(6, maintenance.getStatus());
            stmt.executeUpdate();
        }
    }

    public void updateMaintenance(Maintenance maintenance) throws SQLException {
        String sql = "UPDATE Maintenance SET vehicleId = ?, maintenanceDate = ?, maintenanceType = ?, description = ?, cost = ?, status = ? WHERE maintenanceId = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, maintenance.getVehicleId());
            stmt.setObject(2, maintenance.getMaintenanceDate());
            stmt.setString(3, maintenance.getMaintenanceType());
            stmt.setString(4, maintenance.getDescription());
            stmt.setDouble(5, maintenance.getCost());
            stmt.setString(6, maintenance.getStatus());
            stmt.setInt(7, maintenance.getMaintenanceId());
            stmt.executeUpdate();
        }
    }

    public List<Maintenance> getMaintenanceByVehicleId(int vehicleId) throws SQLException {
        String sql = "SELECT * FROM Maintenance WHERE vehicleId = ?";
        List<Maintenance> maintenanceList = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, vehicleId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Maintenance maintenance = new Maintenance();
                maintenance.setMaintenanceId(rs.getInt("maintenanceId"));
                maintenance.setVehicleId(rs.getInt("vehicleId"));
                maintenance.setMaintenanceDate(rs.getObject("maintenanceDate", LocalDateTime.class));
                maintenance.setMaintenanceType(rs.getString("maintenanceType"));
                maintenance.setDescription(rs.getString("description"));
                maintenance.setCost(rs.getDouble("cost"));
                maintenance.setStatus(rs.getString("status"));
                maintenanceList.add(maintenance);
            }
        }
        return maintenanceList;
    }

    public List<Maintenance> getMaintenanceHistory() throws SQLException {
        String sql = "SELECT * FROM Maintenance";
        List<Maintenance> maintenanceList = new ArrayList<>();
        try (Connection conn = dataSource.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Maintenance maintenance = new Maintenance();
                maintenance.setMaintenanceId(rs.getInt("maintenanceId"));
                maintenance.setVehicleId(rs.getInt("vehicleId"));
                maintenance.setMaintenanceDate(rs.getObject("maintenanceDate", LocalDateTime.class));
                maintenance.setMaintenanceType(rs.getString("maintenanceType"));
                maintenance.setDescription(rs.getString("description"));
                maintenance.setCost(rs.getDouble("cost"));
                maintenance.setStatus(rs.getString("status"));
                maintenanceList.add(maintenance);
            }
        }
        return maintenanceList;
    }
}