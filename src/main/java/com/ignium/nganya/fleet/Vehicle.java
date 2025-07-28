/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.fleet;

/**
 *
 * @author olal
 */
public class Vehicle {
    
    private Long id;
    private String plateNumber;
    private String vehicleModel;
    private String ownerNationalId;
    private int capacity;
    private String sacco;
    private String status;

    // Default constructor
    public Vehicle() {
    }

    // Parameterized constructor
    public Vehicle(String plateNumber, String vehicleModel, String ownerNationalId, int capacity, String sacco) {
        this.plateNumber = plateNumber;
        this.vehicleModel = vehicleModel;
        this.ownerNationalId = ownerNationalId;
        this.capacity = capacity;
        this.sacco = sacco;
    }

    // Getters and Setters
      public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }
    
    public String getPlateNumber() {
        return plateNumber;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }

    public String getVehicleModel() {
        return vehicleModel;
    }

    public void setVehicleModel(String vehicleModel) {
        this.vehicleModel = vehicleModel;
    }

    public String getOwnerNationalId() {
        return ownerNationalId;
    }

    public void setOwnerNationalId(String ownerNationalId) {
        this.ownerNationalId = ownerNationalId;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getSacco() {
        return sacco;
    }

    public void setSacco(String sacco) {
        this.sacco = sacco;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Vehicle{"
                + "plateNumber='" + plateNumber + '\''
                + ", vehicleModel='" + vehicleModel + '\''
                + ", ownerNationalId='" + ownerNationalId + '\''
                + ", capacity=" + capacity
                + ", sacco='" + sacco + '\''
                + ", status='" + status + '\''
                + '}';
    }

}
