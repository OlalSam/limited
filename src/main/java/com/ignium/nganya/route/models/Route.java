/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.models;

import java.time.LocalTime;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Random;

/**
 *
 * @author olal
 */
public class Route {

    private int id;
    private String name;
    private String originStage;
    private String destinationStage;
    private List<Stage> stages;
    private static final TimeRange DEFAULT_OPERATIONAL_HOURS = new TimeRange(
        LocalTime.of(5, 30), // 5:30 AM
        LocalTime.of(22, 30) // 10:30 PM
    );
    private ZonedDateTime createdAt;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getOriginStage() {
        return originStage;
    }

    public void setOriginStage(String originStage) {
        this.originStage = originStage;
    }

    public String getDestinationStage() {
        return destinationStage;
    }

    public void setDestinationStage(String destinationStage) {
        this.destinationStage = destinationStage;
    }

    public List<Stage> getStages() {
        return stages;
    }

    public void setStages(List<Stage> stages) {
        this.stages = stages;
    }

    public TimeRange getOperationalHours() {
        return DEFAULT_OPERATIONAL_HOURS;
    }

    public ZonedDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(ZonedDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public int getLength() {
    // Use java.util.Random to generate a random number
    Random random = new Random();
    
    // Generate random number between 0 and 19, then add 11 to get range 11-30
    return random.nextInt(20) + 11;
}

}
