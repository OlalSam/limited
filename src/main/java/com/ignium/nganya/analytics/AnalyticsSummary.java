package com.ignium.nganya.analytics;

import java.io.Serializable;

public class AnalyticsSummary implements Serializable {
    private int totalTrips;
    private double totalRevenue;
    private double totalProfit;
    private double avgRevenuePerTrip;

    public int getTotalTrips() {
        return totalTrips;
    }

    public void setTotalTrips(int totalTrips) {
        this.totalTrips = totalTrips;
    }

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public double getTotalProfit() {
        return totalProfit;
    }

    public void setTotalProfit(double totalProfit) {
        this.totalProfit = totalProfit;
    }

    public double getAvgRevenuePerTrip() {
        return avgRevenuePerTrip;
    }

    public void setAvgRevenuePerTrip(double avgRevenuePerTrip) {
        this.avgRevenuePerTrip = avgRevenuePerTrip;
    }
}
