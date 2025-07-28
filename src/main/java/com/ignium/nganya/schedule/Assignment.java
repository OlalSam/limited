/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.schedule;

import java.time.LocalDate;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

/**
 *
 * @author olal
 */
public class Assignment {

    private int id;
    private String driverName;
    private String vehiclePlate;
    private String vehicleModel;
    private Date startDate;
    private Date endDate;
    private String status;
    private int vehicleId;

    private Set<LocalDate> assignedDates = new HashSet<>();

    public Assignment() {
    }

    public Assignment(int id, String driverName, String vehiclePlate, String vehicleModel, Date startDate, Date endDate) {
        this.id = id;
        this.driverName = driverName;
        this.vehiclePlate = vehiclePlate;
        this.vehicleModel = vehicleModel;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public int getId() {
        return id;
    }

    public Assignment(int id, String driverName, String vehiclePlate, String vehicleModel, Date startDate, Date endDate, String status) {
        this.id = id;
        this.driverName = driverName;
        this.vehiclePlate = vehiclePlate;
        this.vehicleModel = vehicleModel;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = status;
    }

    public Assignment(int id, String driverName, String vehiclePlate, String vehicleModel, Date startDate, Date endDate, String status, int vehicleId) {
        this.id = id;
        this.driverName = driverName;
        this.vehiclePlate = vehiclePlate;
        this.vehicleModel = vehicleModel;
        this.startDate = startDate;
        this.endDate = endDate;
        this.status = status;
        this.vehicleId = vehicleId;
    }

    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDriverName() {
        return driverName;
    }

    public String getVehiclePlate() {
        return vehiclePlate;
    }

    public String getVehicleModel() {
        return vehicleModel;
    }

    public Date getStartDate() {
        return startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public Set<LocalDate> getAssignedDates() {
        return assignedDates;
    }

    public void setAssignedDates(Set<LocalDate> assignedDates) {
        this.assignedDates = assignedDates;
    }

}
