/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route;

import com.ignium.nganya.route.models.ListOfStageType;
import com.ignium.nganya.route.models.TimeRange;
import com.ignium.nganya.route.models.Route;
import com.ignium.nganya.route.models.RouteAssignment;
import jakarta.annotation.Resource;
import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;
import jakarta.json.bind.Jsonb;
import java.lang.reflect.Type;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.sql.DataSource;
import org.postgresql.util.PGobject;

/**
 *
 * @author olal
 */
@RequestScoped
public class RouteDao implements RouteDaoApi {

    @Resource(lookup = "java:global/nganya1")
    private DataSource dataSource;

    @Inject
    private Jsonb jsonb;

    private static final Type STAGE_LIST_TYPE = new ListOfStageType();

    @Override
    public boolean saveRoute(Route route) {
        String sql = "INSERT INTO routes (name, origin_stage, destination_stage, stages) VALUES (?, ?, ?, ?::jsonb)";

        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, route.getName());
            ps.setString(2, route.getOriginStage());
            ps.setString(3, route.getDestinationStage());
            ps.setString(4, jsonb.toJson(route.getStages()));
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public Route getRouteById(int id) {
        String sql = "SELECT * FROM routes WHERE id = ?";
        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Route r = new Route();
                    r.setId(rs.getInt("id"));
                    r.setName(rs.getString("name"));
                    r.setOriginStage(rs.getString("origin_stage"));
                    r.setDestinationStage(rs.getString("destination_stage"));
                    r.setStages(jsonb.fromJson(rs.getString("stages"), STAGE_LIST_TYPE));
                    r.setCreatedAt(parseCreatedAt(rs.getString("created_at")));
                    return r;
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null;
    }

    @Override
    public List<Route> getAllRoutes(int offset, int pageSize) {
        List<Route> list = new ArrayList<>();
        String sql = "SELECT * FROM routes ORDER BY id DESC LIMIT ? OFFSET ?";
        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pageSize);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Route r = new Route();
                    r.setId(rs.getInt("id"));
                    r.setName(rs.getString("name"));
                    r.setOriginStage(rs.getString("origin_stage"));
                    r.setDestinationStage(rs.getString("destination_stage"));
                    r.setStages(jsonb.fromJson(rs.getString("stages"), STAGE_LIST_TYPE));
                    r.setCreatedAt(parseCreatedAt(rs.getString("created_at")));
                    list.add(r);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean updateRoute(Route route) {
        String sql = "UPDATE routes SET name=?, origin_stage=?, destination_stage=?, stages=? WHERE id=?";
        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, route.getName());
            ps.setString(2, route.getOriginStage());
            ps.setString(3, route.getDestinationStage());

            // Use PGobject for proper JSONB handling
            PGobject jsonObject = new PGobject();
            jsonObject.setType("jsonb");
            jsonObject.setValue(jsonb.toJson(route.getStages()));
            ps.setObject(4, jsonObject);

            ps.setInt(5, route.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteRoute(int id) {
        String sql = "DELETE FROM routes WHERE id = ?";
        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    // Utility to convert TimeRange to PostgreSQL TSRANGE literal
    private String toPgRange(TimeRange range) {
        // Example: Converts LocalTime(5,30) to "2000-01-01 05:30:00"
        String start = "2000-01-01 " + range.getStart().toString();
        String end = "2000-01-01 " + range.getEnd().toString();
        // Format as [start, end) for inclusive lower and exclusive upper
        return String.format("[%s, %s)", start, end);
    }
    // Parse PostgreSQL '[HH:MM,HH:MM)' into TimeRange

    private ZonedDateTime parseCreatedAt(String createdAt) {
        if (createdAt == null || createdAt.isBlank()) {
            return null;
        }
        DateTimeFormatter formatter = new DateTimeFormatterBuilder()
                .appendPattern("yyyy-MM-dd HH:mm:ss")
                .optionalStart()
                .appendFraction(ChronoField.NANO_OF_SECOND, 0, 9, true)
                .optionalEnd()
                .appendPattern("X")
                .toFormatter();
        return ZonedDateTime.parse(createdAt, formatter);
    }

    @Override
    public List<RouteAssignment> driverAssignments(String username) {
        List<RouteAssignment> assignments = new ArrayList<>();
        String sql = """
        SELECT ra.id, ra.vehicle_id, ra.driver_id, ra.route_id, ra.assignment_date, ra.status,
               r.name as route_name, d.first_name, d.second_name, v.plate_number as vehicle_plate
        FROM route_assignments ra
        JOIN routes r ON r.id = ra.route_id
        JOIN users d ON d.id = ra.driver_id
        JOIN vehicle v ON v.id = ra.vehicle_id
        WHERE d.username = ?
        ORDER BY ra.assignment_date DESC
        """;

        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
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
                    assignment.setVehiclePlate(rs.getString("vehicle_plate"));

                    assignments.add(assignment);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }

        return assignments;
    }

    
    public RouteAssignment getClosestActiveAssignment(String username) {
        String sql = """
    SELECT ra.id, ra.vehicle_id, ra.driver_id, ra.route_id, ra.assignment_date, ra.status,
           r.name as route_name, d.first_name, d.second_name, v.plate_number as vehicle_plate,
           DATEDIFF(ra.assignment_date, CURDATE()) as date_diff
    FROM route_assignments ra
    JOIN routes r ON r.id = ra.route_id
    JOIN users d ON d.id = ra.driver_id
    JOIN vehicle v ON v.id = ra.vehicle_id
    WHERE d.username = ?
    ORDER BY 
        CASE 
            WHEN ra.assignment_date >= CURDATE() THEN 0  -- Future/today assignments first
            ELSE 1  -- Past assignments second
        END,
        ABS(DATEDIFF(ra.assignment_date, CURDATE())) ASC,
        ra.assignment_date DESC
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

    @Override
    public List<RouteAssignment> AllAssignments(Date start) {
        List<RouteAssignment> assignments = new ArrayList<>();
        String sql = """
        SELECT ra.id, ra.vehicle_id, ra.driver_id, ra.route_id, ra.assignment_date, ra.status,
               r.name as route_name, d.first_name, d.second_name, v.plate_number as vehicle_plate
        FROM route_assignments ra
        JOIN routes r ON r.id = ra.route_id
        JOIN users d ON d.id = ra.driver_id
        JOIN vehicle v ON v.id = ra.vehicle_id
        WHERE ra.assignment_date >= ?
        ORDER BY ra.assignment_date, r.name
        """;

        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, start);

            try (ResultSet rs = ps.executeQuery()) {
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
                    assignment.setVehiclePlate(rs.getString("vehicle_plate"));

                    assignments.add(assignment);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }

        return assignments;
    }

    @Override
    public Map<String, Integer> routeKpi() {
        Map<String, Integer> kpis = new HashMap<>();
        String sql = "SELECT COUNT(*) as total_routes FROM routes";

        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                kpis.put("totalRoutes", rs.getInt("total_routes"));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return kpis;
    }

}
