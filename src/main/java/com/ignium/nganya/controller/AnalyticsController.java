package com.ignium.nganya.controller;

import com.ignium.nganya.analytics.AnalyticsDao;
import com.ignium.nganya.analytics.AnalyticsSummary;
import com.ignium.nganya.analytics.DetailedAnalytic;
import jakarta.annotation.PostConstruct;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.*;
import java.util.stream.Collectors;

@Named
@ViewScoped
public class AnalyticsController implements Serializable {

    @Inject
    private AnalyticsDao analyticsDao;

    private AnalyticsSummary summary;
    private double revenueGrowth;
    private double tripGrowth;
    private double avgRevenueGrowth;
    private double profitGrowth;
    private String revenueChartJson;
    private String tripDistributionChartJson;
    private String routePerformanceChartJson;
    private List<DetailedAnalytic> detailedAnalytics;

    @PostConstruct
    public void init() {
        loadSummary();
        initRevenueChart();
        initTripDistributionChart();
        initRoutePerformanceChart();
        loadDetailedAnalytics();
    }

    private void loadSummary() {
        Map<String, Object> kpiSummary = analyticsDao.getAnalyticsSummary();
        Map<String, Double> growthRates = analyticsDao.calculateGrowthRates();

        summary = new AnalyticsSummary();
        summary.setTotalTrips((Integer) kpiSummary.getOrDefault("totalTrips", 0));
        summary.setTotalRevenue((Double) kpiSummary.getOrDefault("totalRevenue", 0.0));
        summary.setTotalProfit((Double) kpiSummary.getOrDefault("totalProfit", 0.0));
        summary.setAvgRevenuePerTrip((Double) kpiSummary.getOrDefault("avgRevenuePerTrip", 0.0));

        revenueGrowth = growthRates.getOrDefault("revenue", 0.0);
        tripGrowth = growthRates.getOrDefault("trips", 0.0);
        avgRevenueGrowth = growthRates.getOrDefault("avgRevenue", 0.0);
        profitGrowth = growthRates.getOrDefault("profit", 0.0);
    }

    private void initRevenueChart() {
        List<Object> revenueData = analyticsDao.getRevenueData();
        List<String> labels = analyticsDao.getRevenuePeriodLabels();

        String labelsJson = labels.stream()
                .map(label -> "\"" + label + "\"")
                .collect(Collectors.joining(", ", "[", "]"));

        String dataJson = revenueData.stream()
                .map(String::valueOf)
                .collect(Collectors.joining(", ", "[", "]"));

        revenueChartJson = String.format("""
            {
                "type": "line",
                "data": {
                    "labels": %s,
                    "datasets": [{
                        "label": "Revenue",
                        "data": %s,
                        "fill": false,
                        "borderColor": "rgb(75, 192, 192)",
                        "tension": 0.1
                    }]
                },
                "options": {
                    "responsive": true,
                    "maintainAspectRatio": false,
                    "plugins": {
                        "title": {
                            "display": true,
                            "text": "Revenue Trend"
                        }
                    }
                }
            }
            """, labelsJson, dataJson);
    }

    private void initTripDistributionChart() {
        Map<String, Integer> distribution = analyticsDao.getTripDistribution();
        List<String> labels = new ArrayList<>(distribution.keySet());
        List<Integer> data = new ArrayList<>(distribution.values());
        String labelsJson = labels.stream()
                .map(label -> "\"" + label + "\"")
                .collect(Collectors.joining(", ", "[", "]"));
        String dataJson = data.stream()
                .map(String::valueOf)
                .collect(Collectors.joining(", ", "[", "]"));
        tripDistributionChartJson = String.format("""
        {
            "type": "pie",
            "data": {
                "labels": %s,
                "datasets": [{
                    "data": %s,
                    "backgroundColor": [
                        "rgba(255, 99, 132, 0.6)",
                        "rgba(54, 162, 235, 0.6)",
                        "rgba(255, 205, 86, 0.6)",
                        "rgba(75, 192, 192, 0.6)",
                        "rgba(153, 102, 255, 0.6)",
                        "rgba(201, 203, 207, 0.6)"
                    ],
                    "borderWidth": 1
                }]
            },
            "options": {
                "responsive": true,
                "plugins": {
                    "title": {
                        "display": true,
                        "text": "Trip Distribution by Route"
                    },
                    "legend": {
                        "position": "bottom"
                    }
                }
            }
        }
        """, labelsJson, dataJson);
    }

    private void initRoutePerformanceChart() {
        List<Number> performanceData = analyticsDao.getRoutePerformanceData();
        List<String> routeNames = analyticsDao.getRouteNames();

        String labelsJson = routeNames.stream()
                .map(name -> "\"" + name + "\"")
                .collect(Collectors.joining(", ", "[", "]"));

        String dataJson = performanceData.stream()
                .map(String::valueOf)
                .collect(Collectors.joining(", ", "[", "]"));

        routePerformanceChartJson = String.format("""
            {
                "type": "bar",
                "data": {
                    "labels": %s,
                    "datasets": [{
                        "label": "Average Revenue per Trip",
                        "data": %s,
                        "backgroundColor": "rgba(75, 192, 192, 0.6)",
                        "borderColor": "rgb(75, 192, 192)",
                        "borderWidth": 1
                    }]
                },
                "options": {
                    "responsive": true,
                    "maintainAspectRatio": false,
                    "plugins": {
                        "title": {
                            "display": true,
                            "text": "Route Performance"
                        }
                    },
                    "scales": {
                        "y": {
                            "beginAtZero": true
                        }
                    }
                }
            }
            """, labelsJson, dataJson);
    }

    private void loadDetailedAnalytics() {
        detailedAnalytics = analyticsDao.getDetailedAnalytics();
    }

    // Getters
    public AnalyticsSummary getSummary() {
        return summary;
    }

    public double getRevenueGrowth() {
        return Math.round(this.revenueGrowth * 100.0) / 100.0;
    }

    public double getTripGrowth() {
        return Math.round(this.tripGrowth * 100.0) / 100.0;
    }

    public double getAvgRevenueGrowth() {
        return Math.round(this.avgRevenueGrowth * 100.0) / 100.0;
    }

    public double getProfitGrowth() {
        return Math.round(this.profitGrowth * 100.0) / 100.0;
    }

    public String getRevenueChartJson() {
        return revenueChartJson;
    }

    public String getTripDistributionChartJson() {
        return tripDistributionChartJson;
    }

    public String getRoutePerformanceChartJson() {
        return routePerformanceChartJson;
    }

    public List<DetailedAnalytic> getDetailedAnalytics() {
        return detailedAnalytics;
    }
}
