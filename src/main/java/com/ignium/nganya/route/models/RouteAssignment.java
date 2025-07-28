/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.models;

import java.time.LocalDate;

/**
 *
 * @author olal
 */
public class RouteAssignment {
    private int id;
    private int vehicleId;
    private int driverId;
    private int routeId;
    private java.time.LocalDate assignmentDate;
    private String status;
    
    // Additional fields for display purposes
    private String routeName;
    private String driverName;
    private String vehiclePlate;
    
    // Default constructor
    public RouteAssignment() {
    }
    
    // Getters and setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getVehicleId() { return vehicleId; }
    public void setVehicleId(int vehicleId) { this.vehicleId = vehicleId; }
    
    public int getDriverId() { return driverId; }
    public void setDriverId(int driverId) { this.driverId = driverId; }
    
    public int getRouteId() { return routeId; }
    public void setRouteId(int routeId) { this.routeId = routeId; }
    
    public java.time.LocalDate getAssignmentDate() { return assignmentDate; }
    public void setAssignmentDate(java.time.LocalDate assignmentDate) { this.assignmentDate = assignmentDate; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getRouteName() { return routeName; }
    public void setRouteName(String routeName) { this.routeName = routeName; }
    
    public String getDriverName() { return driverName; }
    public void setDriverName(String driverName) { this.driverName = driverName; }
    
    public String getVehiclePlate() { return vehiclePlate; }
    public void setVehiclePlate(String vehiclePlate) { this.vehiclePlate = vehiclePlate; }
}