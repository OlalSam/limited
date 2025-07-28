package com.ignium.nganya.schedule;

import com.ignium.nganya.fleet.Vehicle;
import com.ignium.nganya.route.*;
import com.ignium.nganya.route.models.Route;
import com.ignium.nganya.route.models.Stage;
import com.ignium.nganya.route.models.VehicleAssignment;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.*;
import java.util.logging.Logger;

/**
 * Service for scheduling vehicles and generating timetables
 *
 * @author olal
 */
@Stateless
public class SchedulerService implements Serializable {

    private static final Logger logger = Logger.getLogger(SchedulerService.class.getName());

    @Inject
    private RouteDaoApi routeDao;
    @Inject
    private RouteKpiDaoApi kpiDao;
    @Inject
    private ScheduleDao assignmentDao;
    @Inject
    private TimetableDaoApi timetableDao;

    /**
     * Allocates vehicles and generates a timetable for the given date.
     *
     * @param date
     */
    public void allocateAndGenerate(LocalDate date) {
        List<Route> routes = routeDao.getAllRoutes(0, Integer.MAX_VALUE);
        for (Route route : routes) {
            // 1. Fetch latest KPI - with null check
            List<RouteKpi> kpis = kpiDao.getLatestKpis(route.getId(), 1);
            if (kpis == null || kpis.isEmpty()) {
                logger.warning("No KPIs found for route " + route.getName() + " (ID: " + route.getId() + "). Skipping timetable generation.");
                continue;
            }
            RouteKpi kpi = kpis.get(0);

            // 2. Compute required vehicles
            int required = determineRequiredVehicles(route);
            // 4. Generate departure times
            List<LocalTime> departures = new ArrayList<>();
            LocalTime start = LocalTime.of(6, 0);  // service start
            for (int i = 0; i < required; i++) {
                departures.add(start.plusSeconds((long) i * kpi.getHeadwayTargetSeconds()));
            }
            // 5. Persist timetable and notify
            timetableDao.saveTimetable(route.getId(), date, departures);
        }
        // Notify managers automatically
        // EMail Service
    }

    /**
     * Generates a weekly schedule starting from the given date. Allocates
     * vehicles to routes for each day of the week.
     *
     * @param startDate The date to start the weekly schedule from (e.g.,
     * 2025-06-08)
     */
    public void generateWeeklySchedule(LocalDate startDate) {
        logger.info("Generating weekly schedule starting from " + startDate);

        // Ensure route_assignments table exists
        assignmentDao.createRouteAssignmentsTableIfNotExists();

        // Retrieve all active routes
        List<Route> allRoutes = routeDao.getAllRoutes(0, Integer.MAX_VALUE);
        logger.info("Found " + allRoutes.size() + " active routes");

        // Define week boundaries
        LocalDate weekStart = startDate;               // e.g., 2025-06-08
        LocalDate weekEnd = startDate.plusDays(6);   // e.g., 2025-06-14

        // Fetch all vehicle assignments whose date-range overlaps [weekStart … weekEnd]
        List<VehicleAssignment> activeAssignments
                = assignmentDao.getActiveAssignments(weekStart, weekEnd);
        logger.info("Found " + activeAssignments.size() + " active vehicle assignments");

        // Keep track of which vehicles have been assigned on which dates (in-memory)
        Map<Integer, Set<LocalDate>> vehicleAssignmentDates = new HashMap<>();

        // Process each day of the target week
        for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
            LocalDate currentDate = startDate.plusDays(dayOffset);
            logger.info("Processing assignments for " + currentDate);

            // For each route, attempt to assign the required number of vehicles
            for (Route route : allRoutes) {
                int requiredVehicles = determineRequiredVehicles(route);
                logger.info("Route \"" + route.getName() + "\" requires " + requiredVehicles + " vehicles");

                List<VehicleAssignment> availableAssignments = new ArrayList<>();

                // Filter activeAssignments down to those that cover currentDate and are not yet used
                for (VehicleAssignment assignment : activeAssignments) {
                    LocalDate assignmentStart = toLocalDate(assignment.getStartDate());
                    LocalDate assignmentEnd   = toLocalDate(assignment.getEndDate());


                    // 1) Skip any inverted date ranges
                    if (assignmentEnd.isBefore(assignmentStart)) {
                        logger.warning("Skipping assignment ID " + assignment.getId()
                                + " because startDate=" + assignmentStart
                                + " is after endDate=" + assignmentEnd);
                        continue;
                    }

                    // 2) Check if currentDate falls inside [assignmentStart … assignmentEnd]
                    if (currentDate.isBefore(assignmentStart) || currentDate.isAfter(assignmentEnd)) {
                        continue;
                    }

                    // 3) (DAO already filtered on status='active')—no need to re-check status
                    // 4) Verify this vehicle is not already recorded in the database for currentDate
                    boolean dbAssigned = assignmentDao.isVehicleAssignedOnDate(
                            assignment.getVehicleId(), currentDate);
                    if (dbAssigned) {
                        continue;
                    }

                    // 5) Verify this vehicle is not already assigned in-memory for currentDate
                    Set<LocalDate> assignedDates
                            = vehicleAssignmentDates.getOrDefault(assignment.getVehicleId(), Collections.emptySet());
                    if (assignedDates.contains(currentDate)) {
                        continue;
                    }

                    // 6) At this point, the assignment truly is available for currentDate
                    availableAssignments.add(assignment);
                }

                logger.info("Found " + availableAssignments.size()
                        + " available vehicles for route \"" + route.getName() + "\" on " + currentDate);

                // If none are available, log a warning and skip to next route
                if (availableAssignments.isEmpty()) {
                    logger.warning("No available vehicles for route \"" + route.getName()
                            + "\" on " + currentDate);
                    continue;
                }

                // Assign up to requiredVehicles from availableAssignments
                int assignedCount = 0;
                for (VehicleAssignment assignment : availableAssignments) {
                    if (assignedCount >= requiredVehicles) {
                        break;
                    }

                    // Persist the route assignment in the database
                    assignmentDao.saveRouteAssignment(
                            assignment.getVehicleId(),
                            assignment.getDriverId(),
                            route.getId(),
                            currentDate,
                            "scheduled"
                    );

                    // Mark this vehicle as assigned for currentDate (in-memory)
                    vehicleAssignmentDates
                            .computeIfAbsent(assignment.getVehicleId(), k -> new HashSet<>())
                            .add(currentDate);

                    logger.info("Assigned vehicle ID " + assignment.getVehicleId()
                            + " to route \"" + route.getName() + "\" on " + currentDate);

                    assignedCount++;
                }

                // If we could not fulfill the requiredVehicles count, log a warning
                if (assignedCount < requiredVehicles) {
                    logger.warning("Only assigned " + assignedCount + " of "
                            + requiredVehicles + " required vehicles for route \""
                            + route.getName() + "\" on " + currentDate);
                }
            }
        }

        logger.info("Weekly schedule generation completed");
    }

    /**
     * Helper: Convert a java.util.Date into java.time.LocalDate. If the date is
     * actually a java.sql.Date, call toLocalDate() directly; otherwise go via
     * Instant/ZoneId.
     */
    private LocalDate toLocalDate(java.util.Date utilDate) {
        if (utilDate == null) {
            return null;
        }
        if (utilDate instanceof java.sql.Date) {
            return ((java.sql.Date) utilDate).toLocalDate();
        } else {
            return utilDate.toInstant()
                    .atZone(ZoneId.systemDefault())
                    .toLocalDate();
        }
    }

    /**
     * Determines how many vehicles are required for a route based on KPIs and
     * route characteristics without relying on stage data
     *
     * @param route The route to check
     * @return Number of vehicles required
     */
    private int determineRequiredVehicles(Route route) {
        // Get latest KPIs with proper null/empty check
        List<RouteKpi> kpis = kpiDao.getLatestKpis(route.getId(), 1);
        if (kpis == null || kpis.isEmpty()) {
            logger.warning("No KPIs found for route " + route.getName() + " (ID: " + route.getId() + "). Using default values.");
            // Return a default number of vehicles when no KPIs are available
            return 3; // or whatever default makes sense for your business logic
        }

        RouteKpi kpi = kpis.get(0);
        long cycleTimeSec;

        // 1) If the Route object has stages in memory, use them
        if (route.getStages() != null && !route.getStages().isEmpty()) {
            long sumStageSec = route.getStages().stream()
                    .mapToLong(Stage::getExpectedTravelTimeSeconds)
                    .sum();
            cycleTimeSec = sumStageSec * 2;         // round-trip
        } // 2) Else if you have a real route length, use that
        else if (route.getLength() > 0) {
            double avgSpeedKmh = new Random().nextDouble(40, 60);
            double hours = (route.getLength() * 2) / avgSpeedKmh;
            cycleTimeSec = (long) (hours * 3600);
            cycleTimeSec += 10 * 60;                // your buffer
        } // 3) Otherwise fall back to your old 60+10 minute default
        else {
            cycleTimeSec = (60 + 10) * 60;
        }

        // Additional safety check for headway target seconds
        long headwaySeconds = kpi.getHeadwayTargetSeconds();
        if (headwaySeconds <= 0) {
            logger.warning("Invalid headway target seconds (" + headwaySeconds + ") for route " + route.getName() + ". Using default headway of 900 seconds (15 minutes).");
            headwaySeconds = 900; // 15 minutes default
        }

        int required = (int) Math.ceil((double) cycleTimeSec / headwaySeconds);
        return Math.max(5, required);
    }
}
