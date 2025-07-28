package com.ignium.nganya.fleet;

import com.ignium.nganya.MessageUtility;
import jakarta.annotation.PostConstruct;
import jakarta.faces.context.Flash;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.List;
import java.util.Map;
import org.primefaces.model.FilterMeta;
import org.primefaces.model.LazyDataModel;
import org.primefaces.model.SortMeta;

@Named("busController")
@ViewScoped     
public class BusController extends LazyDataModel<Vehicle> implements Serializable {
    
    @Inject
    private MessageUtility message;
    
    @Inject
    private BusDao busDao;
    
    @Inject
    private Flash flash;
    
    private Vehicle newBus;
    private Vehicle selectedBus;
    
    @PostConstruct
    public void init(){
        newBus = new Vehicle();
        selectedBus = new Vehicle();
    }
    
    @Override
    public int count(Map<String, FilterMeta> map) {
        // Return actual count from database
        return busDao.getTotalVehicleCount();
    }

    @Override
    public List<Vehicle> load(int offset, int pageSize, Map<String, SortMeta> map, Map<String, FilterMeta> map1) {
        List<Vehicle> busList = busDao.findAll(offset, pageSize);
        // Set the row count for pagination
        this.setRowCount(busDao.getTotalVehicleCount());
        return busList;
    }
    
    // Getters and Setters
    public Vehicle getNewBus() {
        return newBus;
    }
    
    public void setNewBus(Vehicle newBus) {
        this.newBus = newBus;
    }
    
    public Vehicle getSelectedBus() {
        return selectedBus;
    }
    
    public void setSelectedBus(Vehicle selectedBus) {
        this.selectedBus = selectedBus;
    }
    
    /**
     * Add new vehicle
     * @return navigation outcome
     */
    public String addBus() {
        try {
            boolean result = busDao.save(newBus);
            if (result) {
                message.addSuccessMessage("Vehicle added successfully");
                flash.setKeepMessages(true);
                // Reset form
                newBus = new Vehicle();
                return "/admin/fleet.xhtml?faces-redirect=true";
            } else {
                message.addErrorMessage("Error adding vehicle. Please try again.");
                return null; // Stay on current page
            }
        } catch (Exception e) {
            message.addErrorMessage("Error adding vehicle: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Load vehicle for editing
     * @param plateNumber
     * @return 
     */
    public String editVehicle(String plateNumber) {
        try {
            selectedBus = busDao.findByPlateNumber(plateNumber);
            if (selectedBus != null) {
                return null; // Stay on same page, dialog will open
            } else {
                message.addErrorMessage("Vehicle not found.");
                return null;
            }
        } catch (Exception e) {
            message.addErrorMessage("Error loading vehicle: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Update vehicle
     * @return navigation outcome
     */
    public String updateVehicle() {
        try {
            boolean result = busDao.update(selectedBus);
            if (result) {
                message.addSuccessMessage("Vehicle updated successfully");
                flash.setKeepMessages(true);
                return null; // Dialog will close via oncomplete
            } else {
                message.addErrorMessage("Error updating vehicle. Please try again.");
                return null;
            }
        } catch (Exception e) {
            message.addErrorMessage("Error updating vehicle: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Delete vehicle
     * @param plateNumber
     */
    public void deleteVehicle(String plateNumber) {
        try {
            boolean result = busDao.delete(plateNumber);
            if (result) {
                message.addSuccessMessage("Vehicle deleted successfully");
                flash.setKeepMessages(true);
            } else {
                message.addErrorMessage("Error deleting vehicle. Please try again.");
            }
        } catch (Exception e) {
            message.addErrorMessage("Error deleting vehicle: " + e.getMessage());
        }
    }
    
    /**
     * Get all vehicles (for non-lazy loading scenarios)
     * @return list of vehicles
     */
    public List<Vehicle> getAllVehicles() {
        return busDao.findAll(0, Integer.MAX_VALUE);
    }
    
    /**
     * Reset new bus form
     */
    public void resetForm() {
        newBus = new Vehicle();
    }
}