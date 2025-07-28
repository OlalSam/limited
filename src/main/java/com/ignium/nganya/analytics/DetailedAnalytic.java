package com.ignium.nganya.analytics;

import java.io.Serializable;
import java.sql.Date;

public class DetailedAnalytic implements Serializable {
    private Date date;
    private String route;
    private int trips;
    private double revenue;
    private double profit;
    
    public Date getDate() { return date; }
    public void setDate(Date date) { this.date = date; }
    
    public String getRoute() { return route; }
    public void setRoute(String route) { this.route = route; }
    
    public int getTrips() { return trips; }
    public void setTrips(int trips) { this.trips = trips; }
    
    public double getRevenue() { return revenue; }
    public void setRevenue(double revenue) { this.revenue = revenue; }
    
    public double getProfit() { return profit; }
    public void setProfit(double profit) { this.profit = profit; }
}
