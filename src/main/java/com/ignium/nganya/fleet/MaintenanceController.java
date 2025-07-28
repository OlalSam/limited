package com.ignium.nganya.fleet;

import com.ignium.nganya.MessageUtility;
import jakarta.annotation.PostConstruct;
import jakarta.faces.context.Flash;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import java.io.Serializable;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@Named("maintenanceController")
@ViewScoped
public class MaintenanceController implements Serializable {

    @Inject
    private MessageUtility message;

    @Inject
    private MaintenanceDao maintenanceDao;
    
    @Inject
    private BusDao fleetService;
    
    private List<Vehicle> vehicles;

    @Inject
    private Flash flash;

    private Maintenance newMaintenance;
    private Maintenance selectedMaintenance;
    private List<Maintenance> maintenanceHistory;

    @PostConstruct
    public void init() {
        newMaintenance = new Maintenance();
        try {
            maintenanceHistory = maintenanceDao.getMaintenanceHistory();
        } catch (SQLException ex) {
            Logger.getLogger(MaintenanceController.class.getName()).log(Level.SEVERE, null, ex);
            message.addErrorMessage("Error fetching maintainance history");
        }
    }

    public List<Vehicle> getVehicles() {
        vehicles = fleetService.availableVehicles();
        return vehicles;
    }

    
    public List<Maintenance> getMaintenanceHistory() {
        return maintenanceHistory;
    }

    public void setMaintenanceHistory(List<Maintenance> maintenanceHistory) {
        this.maintenanceHistory = maintenanceHistory;
    }

    public Maintenance getNewMaintenance() {
        return newMaintenance;
    }

    public void setNewMaintenance(Maintenance newMaintenance) {
        this.newMaintenance = newMaintenance;
    }

    public Maintenance getSelectedMaintenance() {
        return selectedMaintenance;
    }

    public void setSelectedMaintenance(Maintenance selectedMaintenance) {
        this.selectedMaintenance = selectedMaintenance;
    }

    public String addMaintenance() {
        try {
            maintenanceDao.insertMaintenance(newMaintenance);
            message.addSuccessMessage("Maintenance record added successfully");
            flash.setKeepMessages(true);
            return "maintenance?faces-redirect=true";
        } catch (Exception e) {
            message.addErrorMessage("Error adding maintenance record. Try again.");
            return "maintenanceForm.xhtml";
        }
    }

    public String editMaintenance(int maintenanceId) {
        try {
            List<Maintenance> maintenanceList = maintenanceDao.getMaintenanceHistory();
            selectedMaintenance = maintenanceList.stream()
                    .filter(m -> m.getMaintenanceId() == maintenanceId)
                    .findFirst()
                    .orElse(null);
            if (selectedMaintenance != null) {
                return "REFRESH";
            } else {
                message.addErrorMessage("Maintenance record not found.");
                return "maintenance.xhtml?faces-redirect=true";
            }
        } catch (Exception e) {
            message.addErrorMessage("Error fetching maintenance record.");
            return "maintenance.xhtml?faces-redirect=true";
        }
    }

    public String updateMaintenance() {
        try {
            maintenanceDao.updateMaintenance(selectedMaintenance);
            message.addSuccessMessage("Maintenance record updated successfully");
            flash.setKeepMessages(true);
            return "maintenance.xhtml?faces-redirect=true";
        } catch (Exception e) {
            message.addErrorMessage("Error updating maintenance record. Try again.");
            return "maintenanceForm.xhtml";
        }
    }
} 