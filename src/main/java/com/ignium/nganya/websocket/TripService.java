/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.websocket;

import com.ignium.nganya.analytics.AnalyticsDao;
import com.ignium.nganya.driver.Driver;
import com.ignium.nganya.driver.DriverDao;
import com.ignium.nganya.schedule.Assignment;
import com.ignium.nganya.schedule.ScheduleDao;
import com.ignium.nganya.fleet.BusDao;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 *
 * @author olal
 */
@ApplicationScoped
public class TripService implements Serializable {

    @Inject
    private AnalyticsDao dao;

    @Inject
    private DriverDao emplService;

    @Inject
    private ScheduleDao scheduleDao;

    @Inject
    private BusDao busDao;

    private final Map<String, TripSession> activeTrips = new ConcurrentHashMap<>();

    public boolean recordLocation(LocationUpdate update) {
        Driver driver = emplService.getDriverByUsername(update.getDriverId());
        Assignment va = scheduleDao.findAssignment(driver.getUserId());
        int vehicleId = (va != null) ? va.getVehicleId() : 0;
        boolean result = false;
        
        try {
            dao.recordVehicleLocation(driver.getUserId(), vehicleId, update.getLat(), update.getLng(), Timestamp.valueOf(LocalDateTime.now()));
            result = true;
            return result;
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return result;
    }
    
    public void startTrip(String driverId, double lat, double lng) {
        Driver driver = emplService.getDriverByUsername(driverId);
        Assignment assignment = scheduleDao.findActiveDriverAssignments(driver.getUserId());
        
        TripSession trip = new TripSession();
        trip.setDriverId(driver.getUserId());
        trip.setStartTime(LocalDateTime.now());
        trip.setAssignmentId(assignment.getId());
        trip.setStartLocationType(determineLocationType(lat, lng));
        
        activeTrips.put(driverId, trip);
    }
    
    public void endTrip(String driverId, double lat, double lng) {
        TripSession trip = activeTrips.remove(driverId);
        if (trip != null) {
            LocalDateTime endTime = LocalDateTime.now();
            LocationType endLocationType = determineLocationType(lat, lng);
            trip.setEndTime(endTime);
            trip.setEndLocationType(endLocationType);

            Driver driver = emplService.getDriverByUsername(driverId);
            Assignment assignment = scheduleDao.findActiveDriverAssignments(driver.getUserId());
            String driverUsername = driver.getUsername();
            int vehicleId = assignment.getVehicleId();
            int routeId = assignment.getId(); // or assignment.getRouteId() if available
            String status = "completed";

            // Fetch vehicle capacity
            int vehicleCapacity = busDao.getVehicleCapacityById(vehicleId);

            // Calculate fare per passenger
            BigDecimal farePerPassenger = calculateFare(
                trip.getStartTime(),
                endTime,
                trip.getStartLocationType().toString(),
                isWeekend() ? "WEEKEND" : "WEEKDAY"
            );

            // Calculate total fare
            BigDecimal totalFare = farePerPassenger.multiply(BigDecimal.valueOf(vehicleCapacity));
            trip.setFare(totalFare);

            dao.recordTrip(
                driver.getUserId(),
                driverUsername,
                vehicleId,
                totalFare.doubleValue(),
                routeId,
                Timestamp.valueOf(trip.getStartTime()),
                Timestamp.valueOf(endTime),
                status
            );
        }
    }

    private LocationType determineLocationType(double lat, double lng) {
        // Using the same geofence coordinates from driverMap.js
        double[][] cbdCoordinates = {
            {36.814932, -1.283793}, {36.834377, -1.278729},
            {36.841615, -1.287849}, {36.819990, -1.297579},
            {36.814932, -1.283793}
        };
        
        double[][] largeZoneCoordinates = {
            {36.793850, -1.268661}, {36.868210, -1.234116},
            {36.939121, -1.323920}, {36.863803, -1.358592},
            {36.793850, -1.268661}
        };

        // Check if point is in CBD
        if (isPointInPolygon(lat, lng, cbdCoordinates)) {
            return LocationType.CBD;
        }
        
        // Check if point is in large zone but not in CBD
        if (isPointInPolygon(lat, lng, largeZoneCoordinates)) {
            return LocationType.ESTATE;
        }
        
        // Default to ESTATE if not in any defined zone
        return LocationType.ESTATE;
    }

    private boolean isPointInPolygon(double lat, double lng, double[][] polygon) {
        int i, j;
        boolean result = false;
        for (i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
            if ((polygon[i][1] > lat) != (polygon[j][1] > lat) &&
                (lng < (polygon[j][0] - polygon[i][0]) * (lat - polygon[i][1]) /
                (polygon[j][1] - polygon[i][1]) + polygon[i][0])) {
                result = !result;
            }
        }
        return result;
    }

    private boolean isWeekend() {
        DayOfWeek today = LocalDateTime.now().getDayOfWeek();
        return today == DayOfWeek.SATURDAY || today == DayOfWeek.SUNDAY;
    }

    private BigDecimal calculateFare(LocalDateTime start, LocalDateTime end,
            String locationType, String dayType) {
        boolean isWeekend = "WEEKEND".equalsIgnoreCase(dayType);
        int hour = start.getHour();

        // 1. Weekend rule: flat 70
        if (isWeekend) {
            return BigDecimal.valueOf(70);
        }

        // 2. Weekday rules
        if (hour < 9) {
            // Morning (before 9 AM)
            if ("CBD".equalsIgnoreCase(locationType)) {
                return BigDecimal.valueOf(50);   // non-peak in CBD
            } else {
                return BigDecimal.valueOf(100);  // peak in Estate
            }
        } else if (hour < 16) {
            // Midday (9 AM – 4 PM): constant 70
            return BigDecimal.valueOf(70);
        } else {
            // Evening (after 4 PM)
            if ("CBD".equalsIgnoreCase(locationType)) {
                return BigDecimal.valueOf(100);  // peak in CBD
            } else {
                return BigDecimal.valueOf(50);   // non-peak in Estate
            }
        }
    }
}
