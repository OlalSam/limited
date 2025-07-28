/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.models;

/**
 *
 * @author olal
 */
public class Stage {

    private int stageId;
    private String name;
    private int sequence;
    private double distanceMeters;
    private int expectedTravelTimeSeconds;
    private double latitude;
    private double longitude;

    public int getStageId() {
        return stageId;
    }

    public void setStageId(int stageId) {
        this.stageId = stageId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getSequence() {
        return sequence;
    }

    public void setSequence(int sequence) {
        this.sequence = sequence;
    }

    public double getDistanceMeters() {
        return distanceMeters;
    }

    public void setDistanceMeters(double distanceMeters) {
        this.distanceMeters = distanceMeters;
    }

    public int getExpectedTravelTimeSeconds() {
        return expectedTravelTimeSeconds;
    }

    public void setExpectedTravelTimeSeconds(int expectedTravelTimeSeconds) {
        this.expectedTravelTimeSeconds = expectedTravelTimeSeconds;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

}
