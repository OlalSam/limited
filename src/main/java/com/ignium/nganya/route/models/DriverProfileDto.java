/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.models;

/**
 *
 * @author olal
 */
public class DriverProfileDto {
    private int driverId;
    private String username;
    private String firstName;
    private String lastName;
    private String vehiclePlate;
    private String vehicleModel;

    
    // Constructor, getters, and setters omitted for brevity
    
    public DriverProfileDto(int driverId, String username, String firstName, String lastName, String vehiclePlate, String vehicleModel) {
        this.driverId = driverId;
        this.username = username;
        this.firstName = firstName;
        this.lastName = lastName;
        this.vehiclePlate = vehiclePlate;
        this.vehicleModel = vehicleModel;
    }

    
    
    public DriverProfileDto(int driverId, String username, String firstName, String lastName) {
        this.driverId = driverId;
        this.username = username;
        this.firstName = firstName;
        this.lastName = lastName;
    }

    public int getDriverId() {
        return driverId;
    }

    public void setDriverId(int driverId) {
        this.driverId = driverId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getVehiclePlate() {
        return vehiclePlate;
    }

    public void setVehiclePlate(String vehiclePlate) {
        this.vehiclePlate = vehiclePlate;
    }

    public String getVehicleModel() {
        return vehicleModel;
    }

    public void setVehicleModel(String vehicleModel) {
        this.vehicleModel = vehicleModel;
    }
}
