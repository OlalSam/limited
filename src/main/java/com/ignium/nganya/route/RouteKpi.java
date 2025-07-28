/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route;

import java.time.ZonedDateTime;
import java.util.Map;

/**
 *
 * @author olal
 */
public class RouteKpi {

    private int id;
    private int routeId;
    private ZonedDateTime metricAt;
    private int headwayTargetSeconds;
    private double onTimePerformancePct;
    private Double avgSpeedKmh;
    private Double loadFactorPct;
    private Map<String, Object> extraMetrics;  // maps JSONB keys to values
    private ZonedDateTime updatedAt;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getRouteId() {
        return routeId;
    }

    public void setRouteId(int routeId) {
        this.routeId = routeId;
    }

    public ZonedDateTime getMetricAt() {
        return metricAt;
    }

    public void setMetricAt(ZonedDateTime metricAt) {
        this.metricAt = metricAt;
    }

    public int getHeadwayTargetSeconds() {
        return headwayTargetSeconds;
    }

    public void setHeadwayTargetSeconds(int headwayTargetSeconds) {
        this.headwayTargetSeconds = headwayTargetSeconds;
    }

    public double getOnTimePerformancePct() {
        return onTimePerformancePct;
    }

    public void setOnTimePerformancePct(double onTimePerformancePct) {
        this.onTimePerformancePct = onTimePerformancePct;
    }

    public Double getAvgSpeedKmh() {
        return avgSpeedKmh;
    }

    public void setAvgSpeedKmh(Double avgSpeedKmh) {
        this.avgSpeedKmh = avgSpeedKmh;
    }

    public Double getLoadFactorPct() {
        return loadFactorPct;
    }

    public void setLoadFactorPct(Double loadFactorPct) {
        this.loadFactorPct = loadFactorPct;
    }

    public Map<String, Object> getExtraMetrics() {
        return extraMetrics;
    }

    public void setExtraMetrics(Map<String, Object> extraMetrics) {
        this.extraMetrics = extraMetrics;
    }

    public ZonedDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(ZonedDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "RouteKpi{" + "id=" + id + ", routeId=" + routeId + ", metricAt=" + metricAt + ", headwayTargetSeconds=" + headwayTargetSeconds + ", onTimePerformancePct=" + onTimePerformancePct + ", avgSpeedKmh=" + avgSpeedKmh + ", loadFactorPct=" + loadFactorPct + ", extraMetrics=" + extraMetrics + ", updatedAt=" + updatedAt + '}';
    }
    
    
}
