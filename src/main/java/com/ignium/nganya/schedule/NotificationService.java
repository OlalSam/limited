/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.schedule;

/**
 *
 * @author olal
 */
import com.ignium.nganya.MailUtility;
import com.ignium.nganya.route.models.RouteAssignment;
import com.ignium.nganya.route.service.RouteService;
import com.ignium.nganya.user.User;
import com.ignium.nganya.user.UserService;
import com.ignium.nganya.user.Role;
import com.ignium.nganya.analytics.AnalyticsDao;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.Resource;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.mail.MessagingException;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;
import java.util.logging.Level;
import java.util.logging.Logger;

@Stateless
public class NotificationService {

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm:ss");
    private static final Logger logger = Logger.getLogger(NotificationService.class.getName());

    @Inject
    private MailUtility mailUtil;

    @Inject
    private RouteService routeService;

    @Inject
    private UserService userService;
    
    @Inject
    private AnalyticsDao analyticsDao;
    
    private Map<String, String> adminEmails;

    @PostConstruct
    public void init() {
        adminEmails = new HashMap<>();
        // Load admin emails from database
        List<User> admins = userService.getUsersByRole(Role.ADMIN);
        for (User admin : admins) {
            adminEmails.put(admin.getUsername(), admin.getEmail());
        }
    }

    /**
     * Send weekly schedules: one email per driver, plus a combined master to
     * admins.
     * @param weekStart
     */
    public void sendWeeklySchedules(LocalDate weekStart) {
        LocalDate weekEnd = weekStart.plusDays(6);

        // 1. get all assignments in the week
        List<RouteAssignment> all = routeService.getAllAssignments(weekStart);

        // 2. group by driver
        Map<String, List<RouteAssignment>> byDriver = all.stream()
                .collect(Collectors.groupingBy(routeAssignment -> routeAssignment.getDriverName()));

        // 3. send each driver their personal schedule
        byDriver.forEach((driverUsername, assigns) -> {
            User driver = userService.getUser(driverUsername);
            if (driver != null && driver.getEmail() != null) {
                String subject = String.format("Your Schedule: %s – %s",
                        weekStart.format(DATE_FMT), weekEnd.format(DATE_FMT));
                String bodyHtml = renderDriverSchedule(driverUsername, assigns, weekStart, weekEnd);
                mailUtil.sendHtmlWithErrorHandling(driver.getEmail(), subject, bodyHtml, driver.getUsername()); // log and continue
            }
        });

        // 4. build and send master timetable to admins
        String adminSubject = String.format("Master Timetable: %s – %s",
                weekStart.format(DATE_FMT), weekEnd.format(DATE_FMT));
        String adminBody = renderAdminSchedule(all, weekStart, weekEnd);
        
        // 5. Send weekly analytics report to admins
        sendWeeklyAnalyticsReport(weekStart);
        
        for (String adminEmail : adminEmails.values()) {
            mailUtil.sendHtmlWithErrorHandling(adminEmail, adminSubject, adminBody, adminEmail);
        }
    }

    /**
     * Send weekly analytics report to admin users
     * @param weekStart The start date of the week
     */
    private void sendWeeklyAnalyticsReport(LocalDate weekStart) {
        Map<String, Object> weeklyData = analyticsDao.getWeeklyTripHistory(weekStart);
        
        // Add null checks
        if (weeklyData == null || weeklyData.isEmpty()) {
            logger.warning("No weekly data available for week starting: " + weekStart);
            return;
        }
        
        LocalDate reportStart = (LocalDate) weeklyData.get("weekStart");
        LocalDate reportEnd = (LocalDate) weeklyData.get("weekEnd");
        
        // Validate dates
        if (reportStart == null || reportEnd == null) {
            logger.warning("Invalid report dates for week starting: " + weekStart);
            return;
        }
        
        String subject = String.format("Previous Week Analytics Report: %s – %s",
                reportStart.format(DATE_FMT), reportEnd.format(DATE_FMT));
        
        StringBuilder reportHtml = new StringBuilder();
        reportHtml.append(String.format("""
            <h2>Previous Week Analytics Report</h2>
            <p><em>%s – %s</em></p>
            <div style="margin-bottom: 20px;">
                <h3>Summary</h3>
                <ul>
                    <li>Total Trips: %d</li>
                    <li>Total Revenue: KES %.2f</li>
                </ul>
            </div>
            <h3>Daily Breakdown</h3>
            <table border="1" cellpadding="5" style="border-collapse: collapse;">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Trips</th>
                        <th>Revenue</th>
                        <th>Profit</th>
                        <th>Active Drivers</th>
                        <th>Active Vehicles</th>
                        <th>Avg Trip Duration (hrs)</th>
                    </tr>
                </thead>
                <tbody>
            """,
            reportStart.format(DATE_FMT),
            reportEnd.format(DATE_FMT),
            weeklyData.getOrDefault("totalTrips", 0),
            weeklyData.getOrDefault("totalRevenue", 0.0)
        ));

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> dailyStats = (List<Map<String, Object>>) weeklyData.get("dailyStats");
        if (dailyStats != null) {
            for (Map<String, Object> day : dailyStats) {
                reportHtml.append(String.format("""
                    <tr>
                        <td>%s</td>
                        <td>%d</td>
                        <td>KES %.2f</td>
                        <td>KES %.2f</td>
                        <td>%d</td>
                        <td>%d</td>
                        <td>%.2f</td>
                    </tr>
                    """,
                    ((java.sql.Date)day.get("date")).toLocalDate().format(DATE_FMT),
                    day.getOrDefault("trips", 0),
                    day.getOrDefault("revenue", 0.0),
                    day.getOrDefault("profit", 0.0),
                    day.getOrDefault("activeDrivers", 0),
                    day.getOrDefault("activeVehicles", 0),
                    day.getOrDefault("avgTripDuration", 0.0)
                ));
            }
        }

        reportHtml.append("""
                </tbody>
            </table>
            <hr/>
            <p>This is an automated report showing the previous week's analytics from the Nganya Admin Dashboard.</p>
            """);

        // Send to each admin
        for (String adminEmail : adminEmails.values()) {
            mailUtil.sendHtmlWithErrorHandling(adminEmail, subject, reportHtml.toString(), adminEmail);
        }
    }

    /**
     * Send an immediate alert email when a driver exits the large zone. Now:
     * just name + time + a friendly notification.
     */
    public void sendZoneViolationAlert(String driverUsername, LocalTime time) {
        String subject = "Zone Exit Alert: " + driverUsername;
        String body = String.format("""
        <p>Hello Admin,</p>
        <p>Driver <strong>%s</strong> has left the designated area at <strong>%s</strong>.</p>
        <p>Please check the dashboard for more details or contact the driver directly if needed.</p>
        <hr/>
        <p>Thank you,<br/>Nganya Admin Team</p>
        """,
                driverUsername,
                time.format(TIME_FMT)
        );

        // send to each admin
        for (String admin : adminEmails.values()) {
            mailUtil.sendHtmlWithErrorHandling(admin, subject, body, admin);
        }
    }

    // ───────────────────────────────────────────────────────────────────────────
    // Template rendering methods
    // ───────────────────────────────────────────────────────────────────────────
    private String renderDriverSchedule(String driver,
            List<RouteAssignment> assigns,
            LocalDate start, LocalDate end) {
        StringBuilder rows = new StringBuilder();
        for (RouteAssignment a : assigns) {
            rows.append(String.format("""
                <tr>
                  <td>%s</td>
                  <td>%s</td>
                  <td>%s</td>
                  <td>%s</td>
                  <td>%s</td>
                </tr>""",
                    a.getRouteName(),
                    a.getDriverName(),
                    a.getVehiclePlate(),
                    a.getAssignmentDate().format(DATE_FMT),
                    a.getStatus()
            ));
        }

        return String.format("""
            <h2>Your Weekly Schedule</h2>
            <p><em>%s – %s</em></p>
            <table border="1" cellpadding="5">
              <thead>
                <tr>
                  <th>Route</th><th>Driver</th><th>Vehicle</th><th>Date</th><th>Status</th>
                </tr>
              </thead>
              <tbody>
                %s
              </tbody>
            </table>
            """,
                start.format(DATE_FMT), end.format(DATE_FMT),
                rows.toString()
        );
    }

    private String renderAdminSchedule(List<RouteAssignment> all,
            LocalDate start, LocalDate end) {
        StringBuilder rows = new StringBuilder();
        for (RouteAssignment a : all) {
            rows.append(String.format("""
                <tr>
                  <td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>
                </tr>""",
                    a.getRouteName(),
                    a.getDriverName(),
                    a.getVehiclePlate(),
                    a.getAssignmentDate().format(DATE_FMT),
                    a.getStatus()
            ));
        }

        return String.format("""
            <h2>Master Timetable</h2>
            <p><em>%s – %s</em></p>
            <table border="1" cellpadding="5">
              <thead>
                <tr>
                  <th>Route</th><th>Driver</th><th>Vehicle</th><th>Date</th><th>Status</th>
                </tr>
              </thead>
              <tbody>
                %s
              </tbody>
            </table>
            """,
                start.format(DATE_FMT), end.format(DATE_FMT),
                rows.toString()
        );
    }
}
