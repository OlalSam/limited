package com.ignium.nganya.controller;

import com.ignium.nganya.driver.DriverDao;
import com.ignium.nganya.fleet.BusDaoApi;
import com.ignium.nganya.route.models.RouteAssignment;
import com.ignium.nganya.schedule.Assignment;
import com.ignium.nganya.schedule.ScheduleDao;
import jakarta.annotation.PostConstruct;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.context.FacesContext;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import jakarta.security.enterprise.SecurityContext;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;
import org.primefaces.model.charts.line.LineChartModel;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Set;
import java.util.Map;

@Named("driverDashboard")
@ViewScoped
public class DriverDashboard implements Serializable {

    private static final Logger logger = Logger.getLogger(DriverDashboard.class.getName());
    private static final long serialVersionUID = 1L;

    @Inject
    private SecurityContext securityContext;

    @Inject
    private DriverDao driverDao;

    @Inject
    private BusDaoApi fleetService;

    @Inject
    private ScheduleDao scheduleDao;


    private String username;
    private String status;
    private String driverStatus;
    private String vehiclePlate;
    private String currentRoute;
    private double hoursToday;
    private int fuelLevel;
    private String estimatedArrival;
    private int engineHealth;
    private LineChartModel performanceChart;
    private LocalDateTime lastMaintenanceDate;
    private int daysSinceLastMaintenance;
    private Thread updateThread;
    private RouteAssignment assKpi;

    private static final Set<String> VALID_STATUSES = Set.of("ACTIVE", "BREAK", "OFFLINE");
    private static final Map<String, Set<String>> VALID_TRANSITIONS = Map.of(
        "ACTIVE", Set.of("BREAK", "OFFLINE"),
        "BREAK", Set.of("ACTIVE", "OFFLINE"),
        "OFFLINE", Set.of("ACTIVE")
    );

    @PostConstruct
    public void init() {
        try {
            username = securityContext.getCallerPrincipal().getName();
           
            assKpi = driverDao.getClosestActiveAssignment(username);
            
            // Initialize dashboard KPIs and models
            currentRoute = scheduleDao.getCurrentRoute(username);
            hoursToday = scheduleDao.getHoursWorkedToday(username);
            performanceChart = new LineChartModel();
            
            
            lastMaintenanceDate = LocalDateTime.now().minusDays(15);
            daysSinceLastMaintenance = (int) java.time.temporal.ChronoUnit.DAYS.between(lastMaintenanceDate, LocalDateTime.now());
            
            status = driverDao.getDriverByUsername(username).getStatus();
            vehiclePlate = fleetService.getAssignedVehicle(username);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error initializing dashboard", e);
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error initializing dashboard", e.getMessage()));
        }
    }

   

    // Getters and Setters for fields used in the UI

    public RouteAssignment getAssKpi() {
        return assKpi;
    }

    public void setAssKpi(RouteAssignment assKpi) {
        this.assKpi = assKpi;
    }
    
    
    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDriverStatus() {
        return driverStatus;
    }

    public void setDriverStatus(String driverStatus) {
        this.driverStatus = driverStatus;
    }

    public String getVehiclePlate() {
        vehiclePlate = fleetService.getAssignedVehicle(username);
        return vehiclePlate;
    }

    public String getCurrentRoute() {
        return currentRoute;
    }

    public double getHoursToday() {
        return hoursToday;
    }

    public int getFuelLevel() {
        return fuelLevel;
    }

    public String getEstimatedArrival() {
        return estimatedArrival;
    }

    public int getEngineHealth() {
        return engineHealth;
    }

    public LineChartModel getPerformanceChart() {
        return performanceChart;
    }

    public LocalDateTime getLastMaintenanceDate() {
        return lastMaintenanceDate;
    }

    public void setLastMaintenanceDate(LocalDateTime lastMaintenanceDate) {
        this.lastMaintenanceDate = lastMaintenanceDate;
    }

    public int getDaysSinceLastMaintenance() {
        return daysSinceLastMaintenance;
    }

    public void setDaysSinceLastMaintenance(int daysSinceLastMaintenance) {
        this.daysSinceLastMaintenance = daysSinceLastMaintenance;
    }

    public String getLastMaintenanceDateFormatted() {
        if (lastMaintenanceDate == null) {
            return "";
        }
        return lastMaintenanceDate.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy"));
    }

    public void updateStatus() {
        updateStatus(driverStatus);
    }

    private void updateStatus(String newStatus) {
        if (!VALID_STATUSES.contains(newStatus)) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Invalid status", "Please select a valid status"));
            return;
        }

        if (!VALID_TRANSITIONS.get(status).contains(newStatus)) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Invalid transition", 
                            "Cannot change status from " + status + " to " + newStatus));
            return;
        }

        try {
            boolean success = driverDao.updateDriverStatus(username, newStatus);
            if (success) {
                String oldStatus = status;
                status = newStatus;
                
                
                FacesContext.getCurrentInstance().addMessage(null,
                        new FacesMessage(FacesMessage.SEVERITY_INFO, "Status Updated", 
                                "Your status has been updated to " + newStatus));
            } else {
                FacesContext.getCurrentInstance().addMessage(null,
                        new FacesMessage(FacesMessage.SEVERITY_ERROR, "Update Failed", 
                                "Failed to update status. Please try again."));
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error updating status", e);
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", 
                            "An error occurred while updating status"));
        }
    }
}
