package com.ignium.nganya.websocket;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class TripSession implements Serializable {
    private int driverId;
    private int assignmentId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private BigDecimal fare;
    private LocationType startLocationType;
    private LocationType endLocationType;
    
    // Getters and Setters
    public int getDriverId() {
        return driverId;
    }

    public void setDriverId(int driverId) {
        this.driverId = driverId;
    }

    public int getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public BigDecimal getFare() {
        return fare;
    }

    public void setFare(BigDecimal fare) {
        this.fare = fare;
    }

    public LocationType getStartLocationType() {
        return startLocationType;
    }

    public void setStartLocationType(LocationType startLocationType) {
        this.startLocationType = startLocationType;
    }

    public LocationType getEndLocationType() {
        return endLocationType;
    }

    public void setEndLocationType(LocationType endLocationType) {
        this.endLocationType = endLocationType;
    }
} 