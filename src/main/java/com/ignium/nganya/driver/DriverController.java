package com.ignium.nganya.driver;

import com.ignium.nganya.MessageUtility;
import jakarta.annotation.PostConstruct;
import jakarta.faces.context.Flash;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import jakarta.security.enterprise.SecurityContext;
import java.io.Serializable;
import java.util.List;
import java.util.Map;
import org.primefaces.model.FilterMeta;
import org.primefaces.model.LazyDataModel;
import org.primefaces.model.SortMeta;

/**
 * Controller for managing drivers.
 */
@Named("driverController")
@ViewScoped
public class DriverController extends LazyDataModel<Driver> implements Serializable {
    
    @Inject
    private MessageUtility message;
    
    @Inject
    private DriverDao driverDao;
    
    @Inject
    private Flash flash;
    
    @Inject
    private SecurityContext securityContext;
    
    private Driver newDriver;
    private Driver selectedDriver;
    
    @PostConstruct
    public void init() {
        newDriver = new Driver();
        selectedDriver = new Driver();
    }
    
    @Override
    public int count(Map<String, FilterMeta> filters) {
        // Return actual count from database
        return driverDao.getTotalDriverCount();
        }
    
    @Override
    public List<Driver> load(int offset, int pageSize, Map<String, SortMeta> sortBy, Map<String, FilterMeta> filters) {
        List<Driver> driverList = driverDao.getAllDrivers(offset, pageSize);
        // Set the row count for pagination
        this.setRowCount(driverDao.getTotalDriverCount());
        return driverList;
    }
    
    // Getters and Setters
    public Driver getNewDriver() {
        return newDriver;
    }
    
    public void setNewDriver(Driver newDriver) {
        this.newDriver = newDriver;
    }
    
    public Driver getSelectedDriver() {
        return selectedDriver;
    }
    
    public void setSelectedDriver(Driver selectedDriver) {
        this.selectedDriver = selectedDriver;
    }
    
    /**
     * Get current driver ID from security context
     * @return driver ID
     */
    public String getDriverId() {
        return securityContext.getCallerPrincipal().getName();
    }
    
    /**
     * Add new driver
     * @return navigation outcome
     */
    public String addDriver() {
        try {
            boolean result = driverDao.saveDriver(newDriver);
            if (result) {
                message.addSuccessMessage("Driver added successfully");
                flash.setKeepMessages(true);
                // Reset form
                newDriver = new Driver();
                return "/admin/drivers.xhtml?faces-redirect=true";
            } else {
                message.addErrorMessage("Error adding driver. Please try again.");
                return null; // Stay on current page
            }
        } catch (Exception e) {
            message.addErrorMessage("Error adding driver: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Load driver for editing
     * @param driverId
     * @return navigation outcome
     */
    public String editDriver(int driverId) {
        try {
            selectedDriver = driverDao.getDriverById(driverId);
            if (selectedDriver != null) {
                return null; // Stay on same page, dialog will open
            } else {
                message.addErrorMessage("Driver not found.");
                return null;
            }
        } catch (Exception e) {
            message.addErrorMessage("Error loading driver: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Update driver
     * @return navigation outcome
     */
    public String updateDriver() {
        try {
            boolean result = driverDao.updateDriver(selectedDriver);
            if (result) {
                message.addSuccessMessage("Driver updated successfully");
                return null; // Dialog will close via oncomplete
            } else {
                message.addErrorMessage("updating driver. Please try again.");
                return null;
            }
        } catch (Exception e) {
            message.addErrorMessage("Error updating driver: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Delete driver (mark as inactive)
     * @param driverId
     */
    public void deleteDriver(int driverId) {
        try {
            boolean result = driverDao.deleteDriver(driverId);
            if (result) {
                message.addSuccessMessage("Driver deleted successfully");
            } else {
                message.addErrorMessage(" Please try again.");
            }
        } catch (Exception e) {
            message.addErrorMessage("Error deleting driver: " + e.getMessage());
        }
    }
    
    /**
     * Get all drivers (for non-lazy loading scenarios)
     * @return list of drivers
     */
    public List<Driver> getAllDrivers() {
        return driverDao.getAllDrivers(0, Integer.MAX_VALUE);
    }
    
    /**
     * Reset new driver form
     */
    public void resetForm() {
        newDriver = new Driver();
    }
}