/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.models;

import java.time.LocalTime;

/**
 *
 * @author olal
 */
public class TimeRange {

  
    public TimeRange(LocalTime start, LocalTime end) {
        this.start = start;
        this.end = end;
    }
    private LocalTime start;
    private LocalTime end;
    
    public boolean contains(LocalTime t) {
        return !t.isBefore(start) && t.isBefore(end);
    }

    public LocalTime getStart() {
        return start;
    }

    public void setStart(LocalTime start) {
        this.start = start;
    }

    public LocalTime getEnd() {
        
        return end;
    }

    public void setEnd(LocalTime end) {
        this.end = end;
    }
    
    
}
