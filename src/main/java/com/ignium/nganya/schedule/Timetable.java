/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.schedule;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 *
 * @author olal
 */
class Timetable {
     private int id;
    private String routeName;
    private LocalDate serviceDate;
    private List<LocalTime> departureTimes;

    public Timetable() {
    }

    public Timetable(int id, String routeName, LocalDate serviceDate, List<LocalTime> departureTimes) {
        this.id = id;
        this.routeName = routeName;
        this.serviceDate = serviceDate;
        this.departureTimes = departureTimes;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRouteName() {
        return routeName;
    }

    public void setRouteName(String routeName) {
        this.routeName = routeName;
    }

    public LocalDate getServiceDate() {
        return serviceDate;
    }

    public void setServiceDate(LocalDate serviceDate) {
        this.serviceDate = serviceDate;
    }

    public List<LocalTime> getDepartureTimes() {
        return departureTimes;
    }

    public void setDepartureTimes(List<LocalTime> departureTimes) {
        this.departureTimes = departureTimes;
    }

    @Override
    public String toString() {
        return "Timetable{" +
               "id=" + id +
               ", routeName='" + routeName + '\'' +
               ", serviceDate=" + serviceDate +
               ", departureTimes=" + departureTimes +
               '}';
    }
}
