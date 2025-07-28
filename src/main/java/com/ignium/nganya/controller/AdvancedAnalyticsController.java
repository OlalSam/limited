package com.ignium.nganya.controller;

import com.ignium.nganya.analytics.AdvancedAnalyticsDao;
import jakarta.annotation.PostConstruct;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import java.io.Serializable;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Named("advancedAnalytics")
@ViewScoped
public class AdvancedAnalyticsController implements Serializable {

    @Inject
    private AdvancedAnalyticsDao advancedAnalyticsDao;

    private Map<String, Object> predictiveData;
    private List<Map<String, Object>> routeTrends;
    private Map<String, Object> realTimeMetrics;
    private List<Map<String, Object>> earlyWarnings;
    private List<Map<String, Object>> routeEfficiencyScores;
    private List<Map<String, Object>> optimalVehicleAllocations;
    private List<Map<String, Object>> adaptiveScheduleRecommendations;
    private String predictiveChartJson;
    private String routeTrendsChartJson;
    private String realTimeMetricsChartJson;
    private String efficiencyChartJson;
    private String allocationChartJson;
    private String scheduleChartJson;

    @PostConstruct
    public void init() {
        loadPredictiveAnalytics();
        loadRouteTrends();
        loadRealTimeMetrics();
        loadEarlyWarnings();
        loadRouteEfficiencyScores();
        loadOptimalVehicleAllocations();
        loadAdaptiveScheduleRecommendations();
    }

    private void loadPredictiveAnalytics() {
        predictiveData = advancedAnalyticsDao.getPredictiveAnalytics();
        initPredictiveChart();
    }

    private void loadRouteTrends() {
        routeTrends = advancedAnalyticsDao.getRoutePerformanceTrends();
        initRouteTrendsChart();
    }

    private void loadRealTimeMetrics() {
        realTimeMetrics = advancedAnalyticsDao.getRealTimeMetrics();
        initRealTimeMetricsChart();
    }

    private void loadEarlyWarnings() {
        earlyWarnings = advancedAnalyticsDao.getEarlyWarningIndicators();
    }

    private void loadRouteEfficiencyScores() {
        routeEfficiencyScores = advancedAnalyticsDao.getRouteEfficiencyScores();
        initEfficiencyChart();
    }

    private void loadOptimalVehicleAllocations() {
        optimalVehicleAllocations = advancedAnalyticsDao.getOptimalVehicleAllocation();
        initAllocationChart();
    }

    private void loadAdaptiveScheduleRecommendations() {
        adaptiveScheduleRecommendations = advancedAnalyticsDao.getAdaptiveScheduleRecommendations();
        initScheduleChart();
    }

    private void initPredictiveChart() {
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"type\":\"bar\",");
        json.append("\"data\":{");
        json.append("\"labels\":[\"Average Daily Trips\",\"Average Trip Duration\",\"Average Daily Revenue\",\"Trip Volatility\",\"Trip Revenue Correlation\"],");
        json.append("\"datasets\":[{");
        json.append("\"label\":\"Predictive Metrics\",");
        json.append("\"data\":[");
        json.append(predictiveData.get("avgDailyTrips")).append(",");
        json.append(predictiveData.get("avgTripDuration")).append(",");
        json.append(predictiveData.get("avgDailyRevenue")).append(",");
        json.append(predictiveData.get("tripVolatility")).append(",");
        json.append(predictiveData.get("tripRevenueCorrelation"));
        json.append("],");
        json.append("\"backgroundColor\":[\"#4CAF50\",\"#2196F3\",\"#FFC107\",\"#9C27B0\",\"#F44336\"]");
        json.append("}]");
        json.append("}");
        json.append("}");
        predictiveChartJson = json.toString();
    }

    private void initRouteTrendsChart() {
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"type\":\"line\",");
        json.append("\"data\":{");
        json.append("\"labels\":[");
        for (int i = 0; i < routeTrends.size(); i++) {
            if (i > 0) json.append(",");
            json.append("\"").append(routeTrends.get(i).get("route")).append("\"");
        }
        json.append("],");
        json.append("\"datasets\":[{");
        json.append("\"label\":\"Average Revenue\",");
        json.append("\"data\":[");
        for (int i = 0; i < routeTrends.size(); i++) {
            if (i > 0) json.append(",");
            json.append(routeTrends.get(i).get("avgRevenue"));
        }
        json.append("],");
        json.append("\"borderColor\":\"#4CAF50\",");
        json.append("\"fill\":false");
        json.append("},{");
        json.append("\"label\":\"Average Trips\",");
        json.append("\"data\":[");
        for (int i = 0; i < routeTrends.size(); i++) {
            if (i > 0) json.append(",");
            json.append(routeTrends.get(i).get("avgTrips"));
        }
        json.append("],");
        json.append("\"borderColor\":\"#2196F3\",");
        json.append("\"fill\":false");
        json.append("}]");
        json.append("}");
        json.append("}");
        routeTrendsChartJson = json.toString();
    }

    private void initRealTimeMetricsChart() {
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"type\":\"doughnut\",");
        json.append("\"data\":{");
        json.append("\"labels\":[\"Active Trips\",\"Active Drivers\",\"Active Vehicles\"],");
        json.append("\"datasets\":[{");
        json.append("\"data\":[");
        json.append(realTimeMetrics.get("activeTrips")).append(",");
        json.append(realTimeMetrics.get("activeDrivers")).append(",");
        json.append(realTimeMetrics.get("activeVehicles"));
        json.append("],");
        json.append("\"backgroundColor\":[\"#4CAF50\",\"#2196F3\",\"#FFC107\"]");
        json.append("}]");
        json.append("}");
        json.append("}");
        realTimeMetricsChartJson = json.toString();
    }

    private void initEfficiencyChart() {
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"type\":\"bar\",");
        json.append("\"data\":{");
        json.append("\"labels\":[");
        for (int i = 0; i < routeEfficiencyScores.size(); i++) {
            if (i > 0) json.append(",");
            json.append("\"").append(routeEfficiencyScores.get(i).get("route")).append("\"");
        }
        json.append("],");
        json.append("\"datasets\":[{");
        json.append("\"label\":\"Efficiency Score\",");
        json.append("\"data\":[");
        for (int i = 0; i < routeEfficiencyScores.size(); i++) {
            if (i > 0) json.append(",");
            json.append(routeEfficiencyScores.get(i).get("efficiencyScore"));
        }
        json.append("],");
        json.append("\"backgroundColor\":\"#4CAF50\"");
        json.append("}]");
        json.append("}");
        json.append("}");
        efficiencyChartJson = json.toString();
    }

    private void initAllocationChart() {
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"type\":\"bar\",");
        json.append("\"data\":{");
        json.append("\"labels\":[");
        for (int i = 0; i < optimalVehicleAllocations.size(); i++) {
            if (i > 0) json.append(",");
            json.append("\"").append(optimalVehicleAllocations.get(i).get("route")).append("\"");
        }
        json.append("],");
        json.append("\"datasets\":[{");
        json.append("\"label\":\"Required Vehicles\",");
        json.append("\"data\":[");
        for (int i = 0; i < optimalVehicleAllocations.size(); i++) {
            if (i > 0) json.append(",");
            json.append(optimalVehicleAllocations.get(i).get("requiredVehicles"));
        }
        json.append("],");
        json.append("\"backgroundColor\":\"#4CAF50\"");
        json.append("},{");
        json.append("\"label\":\"Vehicles Used\",");
        json.append("\"data\":[");
        for (int i = 0; i < optimalVehicleAllocations.size(); i++) {
            if (i > 0) json.append(",");
            json.append(optimalVehicleAllocations.get(i).get("vehiclesUsed"));
        }
        json.append("],");
        json.append("\"backgroundColor\":\"#2196F3\"");
        json.append("}]");
        json.append("}");
        json.append("}");
        allocationChartJson = json.toString();
    }

    private void initScheduleChart() {
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"type\":\"line\",");
        json.append("\"data\":{");
        json.append("\"labels\":[");
        for (int i = 0; i < adaptiveScheduleRecommendations.size(); i++) {
            if (i > 0) json.append(",");
            json.append("\"").append(adaptiveScheduleRecommendations.get(i).get("hourOfDay")).append(":00\"");
        }
        json.append("],");
        json.append("\"datasets\":[{");
        json.append("\"label\":\"Current Trips\",");
        json.append("\"data\":[");
        for (int i = 0; i < adaptiveScheduleRecommendations.size(); i++) {
            if (i > 0) json.append(",");
            json.append(adaptiveScheduleRecommendations.get(i).get("tripCount"));
        }
        json.append("],");
        json.append("\"borderColor\":\"#4CAF50\",");
        json.append("\"fill\":false");
        json.append("},{");
        json.append("\"label\":\"Recommended Trips\",");
        json.append("\"data\":[");
        for (int i = 0; i < adaptiveScheduleRecommendations.size(); i++) {
            if (i > 0) json.append(",");
            json.append(adaptiveScheduleRecommendations.get(i).get("recommendedTrips"));
        }
        json.append("],");
        json.append("\"borderColor\":\"#2196F3\",");
        json.append("\"fill\":false");
        json.append("}]");
        json.append("}");
        json.append("}");
        scheduleChartJson = json.toString();
    }

    // Getters
    public Map<String, Object> getPredictiveData() {
        return predictiveData;
    }

    public List<Map<String, Object>> getRouteTrends() {
        return routeTrends;
    }

    public Map<String, Object> getRealTimeMetrics() {
        return realTimeMetrics;
    }

    public List<Map<String, Object>> getEarlyWarnings() {
        return earlyWarnings;
    }

    public List<Map<String, Object>> getRouteEfficiencyScores() {
        return routeEfficiencyScores;
    }

    public List<Map<String, Object>> getOptimalVehicleAllocations() {
        return optimalVehicleAllocations;
    }

    public List<Map<String, Object>> getAdaptiveScheduleRecommendations() {
        return adaptiveScheduleRecommendations;
    }

    public String getPredictiveChartJson() {
        return predictiveChartJson;
    }

    public String getRouteTrendsChartJson() {
        return routeTrendsChartJson;
    }

    public String getRealTimeMetricsChartJson() {
        return realTimeMetricsChartJson;
    }

    public String getEfficiencyChartJson() {
        return efficiencyChartJson;
    }

    public String getAllocationChartJson() {
        return allocationChartJson;
    }

    public String getScheduleChartJson() {
        return scheduleChartJson;
    }
} 