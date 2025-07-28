/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route;

import com.ignium.nganya.route.models.RouteTimePattern;
import com.ignium.nganya.route.models.TimeRange;
import jakarta.annotation.Resource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;

/**
 *
 * @author olal
 */
public class RouteTimePatternDao implements RouteTimePatternDaoApi {
    @Resource(lookup = "java:global/nganya1")
    private DataSource dataSource;

    @Override
    public boolean saveTimePattern(RouteTimePattern p) {
        String sql = "INSERT INTO route_time_patterns (route_id, stage, time_slot, demand_factor, vehicle_requirement) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = dataSource.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getRouteId());
            ps.setString(2, p.getStage());
            ps.setString(3, toPgRange(p.getTimeSlot()));
            ps.setDouble(4, p.getDemandFactor());
            ps.setObject(5, p.getVehicleRequirement());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public RouteTimePattern getTimePatternById(int id) {
        String sql = "SELECT * FROM route_time_patterns WHERE id = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RouteTimePattern p = new RouteTimePattern();
                    p.setId(rs.getInt("id"));
                    p.setRouteId(rs.getInt("route_id"));
                    p.setStage(rs.getString("stage"));
                    p.setTimeSlot(parseTimeRange(rs.getString("time_slot")));
                    p.setDemandFactor(rs.getDouble("demand_factor"));
                    p.setVehicleRequirement((Integer)rs.getObject("vehicle_requirement"));
                    return p;
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null;
    }

    @Override
    public List<RouteTimePattern> getPatternsForRoute(int routeId) {
        List<RouteTimePattern> list = new ArrayList<>();
        String sql = "SELECT id FROM route_time_patterns WHERE route_id = ? ORDER BY time_slot";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, routeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(getTimePatternById(rs.getInt("id")));
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean updateTimePattern(RouteTimePattern p) {
        String sql = "UPDATE route_time_patterns SET stage=?, time_slot=?, demand_factor=?, vehicle_requirement=? WHERE id=?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getStage());
            ps.setString(2, toPgRange(p.getTimeSlot()));
            ps.setDouble(3, p.getDemandFactor());
            ps.setObject(4, p.getVehicleRequirement());
            ps.setInt(5, p.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteTimePattern(int id) {
        String sql = "DELETE FROM route_time_patterns WHERE id = ?";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    private String toPgRange(TimeRange tr) {
        return String.format("[%s,%s)", tr.getStart(), tr.getEnd());
    }

    private TimeRange parseTimeRange(String pgRange) {
        String inner = pgRange.substring(1, pgRange.length() - 1);
        String[] parts = inner.split(",");
        return new TimeRange(LocalTime.parse(parts[0]), LocalTime.parse(parts[1]));
    }
}
