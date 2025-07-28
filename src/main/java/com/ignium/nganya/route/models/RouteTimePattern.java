/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.models;

import com.ignium.nganya.route.models.TimeRange;

/**
 *
 * @author olal
 */
public class RouteTimePattern {
    private int id;
    private int routeId;
    private String stage;
    private TimeRange timeSlot;
    private double demandFactor;
    private Integer vehicleRequirement;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getRouteId() {
        return routeId;
    }

    public void setRouteId(int routeId) {
        this.routeId = routeId;
    }

    public String getStage() {
        return stage;
    }

    public void setStage(String stage) {
        this.stage = stage;
    }

    public TimeRange getTimeSlot() {
        return timeSlot;
    }

    public void setTimeSlot(TimeRange timeSlot) {
        this.timeSlot = timeSlot;
    }

    public double getDemandFactor() {
        return demandFactor;
    }

    public void setDemandFactor(double demandFactor) {
        this.demandFactor = demandFactor;
    }

    public Integer getVehicleRequirement() {
        return vehicleRequirement;
    }

    public void setVehicleRequirement(Integer vehicleRequirement) {
        this.vehicleRequirement = vehicleRequirement;
    }
    
    
}
