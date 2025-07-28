package com.ignium.nganya.model;

import java.io.Serializable;

public class Notification implements Serializable {
    private static final long serialVersionUID = 1L;
    
    public int id;
    public String title;
    public String message;
    public String icon;
    public String color;
    public String time;
    
    public Notification() {
        // Default constructor
    }
    
    public Notification(String title, String message, String icon, String color) {
        this.title = title;
        this.message = message;
        this.icon = icon;
        this.color = color;
    }
} 