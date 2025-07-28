package com.ignium.nganya.schedule;

import com.ignium.nganya.MessageUtility;
import com.ignium.nganya.driver.Driver;
import com.ignium.nganya.driver.DriverDao;
import com.ignium.nganya.fleet.BusDao;
import com.ignium.nganya.fleet.Vehicle;
import com.ignium.nganya.MailUtility;
import com.ignium.nganya.schedule.NotificationService;
import jakarta.annotation.PostConstruct;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.context.FacesContext;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author olal
 */
@Named("schedule")
@ViewScoped
public class ScheduleController implements Serializable {

    private final MessageUtility message = new MessageUtility();
    private static final Logger logger = Logger.getLogger(ScheduleController.class.getName());

    private List<Vehicle> vehicles;
    private List<Driver> drivers;
    private Integer selectedVehicleId;
    private Integer selectedDriverId;
    private java.util.Date startDate;
    private java.util.Date currentDate;

    private java.util.Date endDate;
    private List<Assignment> assignments;
    private String filterStatus;

    public Date getCurrentDate() {

        return currentDate;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    @Inject
    private SchedulerService scheduler;

    @Inject
    private TimetableDaoApi timetableDao;

    @Inject
    private ScheduleDao scheduleDao;

    @Inject
    private BusDao busService;

    @Inject
    private DriverDao driverService;

    @Inject
    private MailUtility mailUtility;

    @Inject
    private NotificationService notificationService;

    private LocalDate serviceDate;
    private List<Timetable> timetables;

    @PostConstruct
    public void init() {
        // default to today
        serviceDate = LocalDate.now();
        loadTimetables();
        drivers = driverService.availableDrivers();
        vehicles = busService.availableVehicles();
        assignments = scheduleDao.loadAssignments();

    }

    public void unassignVehicle(Integer id, String plateNumber) {
        try {
            boolean result = scheduleDao.unassignVehicle(id);
            if (result) {
                busService.vehicleStatus("available", plateNumber);
                assignments = scheduleDao.loadAssignments();
                message.addSuccessMessage("Assignment cancelled ");
            } else {
                message.addErrorMessage("Please try again.");
            }
        } catch (Exception e) {
            message.addErrorMessage("Error anassigning : " + e.getMessage());
        }
    }

    /**
     * Runs your allocation + generation logic, then reloads the table
     */
    public void runAllocation() {
        try {
            scheduler.allocateAndGenerate(serviceDate);
            loadTimetables();
            // add a growl or message here if you have a MessageUtility
        } catch (Exception ex) {
            // handle/log
        }
    }

    public void weeklySchedule() {
        try {
            // Generate the weekly schedule
            scheduler.generateWeeklySchedule(serviceDate);

            // Send notifications to drivers and admins
            notificationService.sendWeeklySchedules(serviceDate);

            // Update UI
            message.addSuccessMessage("Weekly schedule generated and notifications sent successfully");
            loadTimetables();
        } catch (Exception ex) {
            logger.log(Level.SEVERE, "Error generating weekly schedule", ex);
            message.addErrorMessage("Error generating weekly schedule: " + ex.getMessage());
        }
    }

    public void assignVehicle() {
        if (selectedDriverId == null || selectedVehicleId == null || startDate == null || endDate == null) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "All fields are required!"));
            return;
        }

        // Convert java.util.Date to java.sql.Date
        java.sql.Date sqlStartDate = new java.sql.Date(startDate.getTime());
        java.sql.Date sqlEndDate = new java.sql.Date(endDate.getTime());

        // Check for overlapping vehicle assignments
        if (scheduleDao.hasOverlappingAssignments(selectedVehicleId.intValue(), sqlStartDate, sqlEndDate)) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Vehicle is already assigned during this period!"));
            return;
        }

        // Check for overlapping driver assignments
        if (scheduleDao.hasOverlappingDriverAssignments(selectedDriverId.intValue(), sqlStartDate, sqlEndDate)) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Driver is already assigned to another vehicle during this period!"));
            return;
        }

        scheduleDao.assignVehicle(selectedDriverId, selectedVehicleId, sqlStartDate, sqlEndDate);

        // Get driver and vehicle details for email
        Driver driver = driverService.getDriverById(selectedDriverId);
        Vehicle vehicle = busService.getVehicleById(selectedVehicleId);

        if (driver != null && vehicle != null) {
            try {
                // Send email notification using MailUtility
                String subject = "New Vehicle Assignment";

                // Build an HTML body
                String htmlBody = String.format("""
        <html>
          <body style="font-family: Arial, sans-serif; line-height: 1.4; color: #333;">
            <p>Dear <strong>%s</strong>,</p>
            
            <p style="margin-top: 1em;">
              You have been <span style="color: #2d6cdf;"><strong>assigned a new vehicle</strong></span>:
            </p>
            
            <table style="border-collapse: collapse; width: 100%%; max-width: 400px;">
              <tr>
                <td style="padding: 8px 12px; border: 1px solid #ddd; background:#f9f9f9;"><strong>Vehicle:</strong></td>
                <td style="padding: 8px 12px; border: 1px solid #ddd;">%s</td>
              </tr>
              <tr>
                <td style="padding: 8px 12px; border: 1px solid #ddd; background:#f9f9f9;"><strong>Start Date:</strong></td>
                <td style="padding: 8px 12px; border: 1px solid #ddd;">%s</td>
              </tr>
              <tr>
                <td style="padding: 8px 12px; border: 1px solid #ddd; background:#f9f9f9;"><strong>End Date:</strong></td>
                <td style="padding: 8px 12px; border: 1px solid #ddd;">%s</td>
              </tr>
            </table>
            
            <p style="margin-top: 1em;">
              Please ensure you are available for this assignment. If you have any questions, reply to this email.
            </p>
            
            <p style="margin-top: 2em; font-size: 0.9em; color: #666;">
              —<br/>
              <strong>Nganya Admin Dashboard</strong>
            </p>
          </body>
        </html>
        """,
                        driver.getUsername(),
                        vehicle.getPlateNumber(),
                        new java.text.SimpleDateFormat("yyyy-MM-dd").format(startDate),
                        new java.text.SimpleDateFormat("yyyy-MM-dd").format(endDate)
                );

                mailUtility.sendHtmlWithErrorHandling(
                        driver.getEmail(),
                        subject,
                        htmlBody,
                        driver.getUsername()
                );
            } catch (Exception ex) {
                logger.log(Level.WARNING, "Failed to send email notification", ex);
            }
        }

        FacesContext.getCurrentInstance().addMessage(null,
                new FacesMessage(FacesMessage.SEVERITY_INFO, "Success", "Vehicle assigned successfully email sent !"));

        busService.vehicleStatus("assigned", vehicle.getPlateNumber());

        // Refresh the assignments list
        assignments = scheduleDao.loadAssignments();

        // Clear the form
        selectedDriverId = null;
        selectedVehicleId = null;
        startDate = null;
        endDate = null;
    }

    /**
     * Pulls the saved timetables for the selected date
     */
    public void loadTimetables() {
        timetables = timetableDao.findByServiceDate(serviceDate);
    }

    // getters & setters
    public Integer getSelectedVehicleId() {
        return selectedVehicleId;
    }

    public void setSelectedVehicleId(Integer selectedVehicleId) {
        this.selectedVehicleId = selectedVehicleId;
    }

    public List<Assignment> getAssignments() {
        return assignments;
    }

    public void setAssignments(List<Assignment> assignments) {
        this.assignments = assignments;
    }

    public LocalDate getServiceDate() {
        return serviceDate;
    }

    public void setServiceDate(LocalDate serviceDate) {
        this.serviceDate = serviceDate;
    }

    public List<Timetable> getTimetables() {
        return timetables;
    }

    public Integer getSelectedDriverId() {
        return selectedDriverId;
    }

    public void setSelectedDriverId(Integer selectedDriverId) {
        this.selectedDriverId = selectedDriverId;
    }

    public List<Vehicle> getVehicles() {
        return vehicles;
    }

    public void setVehicles(List<Vehicle> vehicles) {
        this.vehicles = vehicles;
    }

    public List<Driver> getDrivers() {
        return drivers;
    }

    public void setDrivers(List<Driver> drivers) {
        this.drivers = drivers;
    }

    public String getFilterStatus() {
        return filterStatus;
    }

    public void setFilterStatus(String filterStatus) {
        this.filterStatus = filterStatus;
    }

    public List<Assignment> getFilteredAssignments() {
        if (filterStatus == null || filterStatus.isEmpty()) {
            return assignments;
        }
        return assignments.stream()
                .filter(a -> a.getStatus().equals(filterStatus))
                .collect(Collectors.toList());
    }

    public void setFilteredAssignments(List<Assignment> filteredAssignments) {
    }

    public int getActiveAssignmentsCount() {
        if (assignments == null) {
            return 0;
        }
        return (int) assignments.stream()
                .filter(a -> "active".equals(a.getStatus()))
                .count();
    }

    public int getAvailableVehiclesCount() {
        if (vehicles == null) {
            return 0;
        }
        return vehicles.size();
    }
}
