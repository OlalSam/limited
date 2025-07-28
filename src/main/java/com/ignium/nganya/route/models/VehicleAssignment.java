/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.models;

import java.sql.Date;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

/**
 *
 * @author olal
 */
public class VehicleAssignment {
    private int id;
    private int vehicleId;
    private int driverId;
    private java.util.Date startDate;
    private java.util.Date endDate;
    private String status;
    
    // For conflict tracking (not persisted)
    private transient java.util.Set<java.time.LocalDate> assignedDates = new java.util.HashSet<>();
    
    // Default constructor
    public VehicleAssignment() {
    }
    
    // Getters and setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getVehicleId() { return vehicleId; }
    public void setVehicleId(int vehicleId) { this.vehicleId = vehicleId; }
    
    public int getDriverId() { return driverId; }
    public void setDriverId(int driverId) { this.driverId = driverId; }
    
    public java.util.Date getStartDate() { return startDate; }
    public void setStartDate(java.util.Date startDate) { this.startDate = startDate; }
    
    public java.util.Date getEndDate() { return endDate; }
    public void setEndDate(java.util.Date endDate) { this.endDate = endDate; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    // Track assigned dates to prevent conflicts
    public boolean isAssignedForDate(java.time.LocalDate date) {
        return assignedDates.contains(date);
    }
    
    public void setAssignedForDate(java.time.LocalDate date) {
        assignedDates.add(date);
    }

    @Override
    public String toString() {
        return "VehicleAssignment{" + "id=" + id + ", vehicleId=" + vehicleId + ", driverId=" + driverId + ", startDate=" + startDate + ", endDate=" + endDate + ", status=" + status + ", assignedDates=" + assignedDates + '}';
    }
    
}
