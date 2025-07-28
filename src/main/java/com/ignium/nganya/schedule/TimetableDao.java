/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.schedule;

import jakarta.annotation.Resource;
import jakarta.enterprise.context.RequestScoped;
import java.sql.Array;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import javax.sql.DataSource;

/**
 *
 * @author olal
 */
@RequestScoped
public class TimetableDao implements TimetableDaoApi {

    @Resource(lookup = "java:global/nganya1")
    private DataSource dataSource;

    private static final Logger logger = Logger.getLogger(TimetableDao.class.getName());

    @Override
    public boolean saveTimetable(int routeId, LocalDate serviceDate, List<LocalTime> departures) {
        String sql = """
            INSERT INTO route_timetables (route_id, service_date, departure_times)
            VALUES (?, ?, ?)
            """;
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            // 1. Set scalars
            ps.setInt(1, routeId);
            ps.setDate(2, Date.valueOf(serviceDate));
            // 2. Convert List<LocalTime> to java.sql.Array for TIME[] :contentReference[oaicite:8]{index=8}
            String[] times = departures.stream()
                    .map(LocalTime::toString)
                    .toArray(String[]::new);
            // driver.createArrayOf expects PG type name & Java array :contentReference[oaicite:9]{index=9}
            Array array = conn.createArrayOf("time", times);
            ps.setArray(3, array);

            ps.executeUpdate();
            return true;
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error saving timetable", ex);
            return false;
        }
    }

    /**
     *
     * @param date
     * @return
     */
    @Override
    public List<Timetable> findByServiceDate(LocalDate date) {
        String sql
                = "SELECT t.id, r.name as route_name, t.departure_times "
                + "  FROM route_timetables t "
                + "  JOIN routes r ON r.id = t.route_id "
                + " WHERE t.service_date = ?";
        List<Timetable> list = new ArrayList<>();
        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setObject(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Timetable tt = new Timetable();
                    tt.setId(rs.getInt("id"));
                    tt.setRouteName(rs.getString("route_name"));
                    Array arr = rs.getArray("departure_times");
                    Object arrayData = arr.getArray();
                    List<LocalTime> deps = new ArrayList<>();

                    if (arrayData instanceof java.sql.Time[]) {
                        // Handle case where database returns Time[] objects
                        java.sql.Time[] timeArray = (java.sql.Time[]) arrayData;
                        for (java.sql.Time time : timeArray) {
                            deps.add(time.toLocalTime());
                        }
                    } else if (arrayData instanceof String[]) {
                        // Handle case where database returns String[] objects
                        String[] timeArray = (String[]) arrayData;
                        deps = Arrays.stream(timeArray)
                                .map(LocalTime::parse)
                                .collect(Collectors.toList());
                    }

                    tt.setDepartureTimes(deps);
                    list.add(tt);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(TimetableDao.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
}
