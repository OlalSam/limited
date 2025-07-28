package com.ignium.nganya.analytics;

import jakarta.annotation.Resource;
import jakarta.ejb.Stateless;
import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

@Stateless
public class AdvancedAnalyticsDao {
    @Resource(lookup = "java:global/nganya1")
    private DataSource dataSource;
    private static final Logger logger = Logger.getLogger(AdvancedAnalyticsDao.class.getName());

    public void setDataSource(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public Map<String, Object> getPredictiveAnalytics() {
        Map<String, Object> predictiveData = new HashMap<>();
        String sql = """
            WITH daily_stats AS (
                SELECT 
                    DATE(start_time) as date,
                    COUNT(*) as trips,
                    AVG(EXTRACT(EPOCH FROM (end_time - start_time))/3600) as avg_duration,
                    SUM(f.revenue) as revenue
                FROM trips t
                JOIN financials f ON t.trip_id = f.trip_id
                GROUP BY DATE(start_time)
            )
            SELECT 
                AVG(trips) as avg_daily_trips,
                AVG(avg_duration) as avg_trip_duration,
                AVG(revenue) as avg_daily_revenue,
                STDDEV(trips) as trip_volatility,
                CORR(trips, revenue) as trip_revenue_correlation
            FROM daily_stats
            WHERE date >= CURRENT_DATE - INTERVAL '90 days'
        """;
        
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                predictiveData.put("avgDailyTrips", rs.getDouble("avg_daily_trips"));
                predictiveData.put("avgTripDuration", rs.getDouble("avg_trip_duration"));
                predictiveData.put("avgDailyRevenue", rs.getDouble("avg_daily_revenue"));
                predictiveData.put("tripVolatility", rs.getDouble("trip_volatility"));
                predictiveData.put("tripRevenueCorrelation", rs.getDouble("trip_revenue_correlation"));
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting predictive analytics", ex);
        }
        return predictiveData;
    }

    public List<Map<String, Object>> getRoutePerformanceTrends() {
        List<Map<String, Object>> trends = new ArrayList<>();
        String sql = """
            WITH route_daily_stats AS (
                SELECT 
                    r.name as route,
                    DATE(t.start_time) as date,
                    COUNT(*) as trips,
                    AVG(f.revenue) as avg_revenue,
                    AVG(EXTRACT(EPOCH FROM (t.end_time - t.start_time))/3600) as avg_duration
                FROM trips t
                JOIN routes r ON t.route_id = r.id
                JOIN financials f ON t.trip_id = f.trip_id
                WHERE t.start_time >= CURRENT_DATE - INTERVAL '30 days'
                GROUP BY r.name, DATE(t.start_time)
            )
            SELECT 
                route,
                AVG(trips) as avg_trips,
                AVG(avg_revenue) as avg_revenue,
                AVG(avg_duration) as avg_duration,
                STDDEV(trips) as trip_volatility,
                CORR(trips, avg_revenue) as trip_revenue_correlation
            FROM route_daily_stats
            GROUP BY route
            ORDER BY avg_revenue DESC
        """;
        
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Map<String, Object> trend = new HashMap<>();
                trend.put("route", rs.getString("route"));
                trend.put("avgTrips", rs.getDouble("avg_trips"));
                trend.put("avgRevenue", rs.getDouble("avg_revenue"));
                trend.put("avgDuration", rs.getDouble("avg_duration"));
                trend.put("tripVolatility", rs.getDouble("trip_volatility"));
                trend.put("tripRevenueCorrelation", rs.getDouble("trip_revenue_correlation"));
                trends.add(trend);
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting route performance trends", ex);
        }
        return trends;
    }

    public Map<String, Object> getRealTimeMetrics() {
        Map<String, Object> metrics = new HashMap<>();
        String sql = """
            WITH current_hour_stats AS (
                SELECT 
                    COUNT(*) as active_trips,
                    COUNT(DISTINCT driver_id) as active_drivers,
                    COUNT(DISTINCT vehicle_id) as active_vehicles,
                    AVG(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - start_time))/3600) as avg_trip_duration
                FROM trips
                WHERE start_time >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
                AND end_time IS NULL
            )
            SELECT 
                active_trips,
                active_drivers,
                active_vehicles,
                avg_trip_duration
            FROM current_hour_stats
        """;
        
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                metrics.put("activeTrips", rs.getInt("active_trips"));
                metrics.put("activeDrivers", rs.getInt("active_drivers"));
                metrics.put("activeVehicles", rs.getInt("active_vehicles"));
                metrics.put("avgTripDuration", rs.getDouble("avg_trip_duration"));
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting real-time metrics", ex);
        }
        return metrics;
    }

    public List<Map<String, Object>> getEarlyWarningIndicators() {
        List<Map<String, Object>> warnings = new ArrayList<>();
        String sql = """
            WITH route_performance AS (
                SELECT 
                    r.name as route,
                    COUNT(*) as trips,
                    AVG(f.revenue) as avg_revenue,
                    AVG(EXTRACT(EPOCH FROM (t.end_time - t.start_time))/3600) as avg_duration
                FROM trips t
                JOIN routes r ON t.route_id = r.id
                JOIN financials f ON t.trip_id = f.trip_id
                WHERE t.start_time >= CURRENT_DATE - INTERVAL '7 days'
                GROUP BY r.name
            )
            SELECT 
                route,
                trips,
                avg_revenue,
                avg_duration,
                CASE 
                    WHEN trips < 10 THEN 'Low Trip Volume'
                    WHEN avg_revenue < 1000 THEN 'Low Revenue'
                    WHEN avg_duration > 2 THEN 'Long Trip Duration'
                    ELSE 'Normal'
                END as warning_type
            FROM route_performance
            WHERE trips < 10 OR avg_revenue < 1000 OR avg_duration > 2
        """;
        
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Map<String, Object> warning = new HashMap<>();
                warning.put("route", rs.getString("route"));
                warning.put("trips", rs.getInt("trips"));
                warning.put("avgRevenue", rs.getDouble("avg_revenue"));
                warning.put("avgDuration", rs.getDouble("avg_duration"));
                warning.put("warningType", rs.getString("warning_type"));
                warnings.add(warning);
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting early warning indicators", ex);
        }
        return warnings;
    }

    public List<Map<String, Object>> getRouteEfficiencyScores() {
        List<Map<String, Object>> efficiencyScores = new ArrayList<>();
        String sql = """
            WITH route_metrics AS (
                SELECT 
                    r.name as route,
                    COUNT(*) as total_trips,
                    AVG(f.revenue) as avg_revenue,
                    AVG(f.profit) as avg_profit,
                    AVG(f.expenses) as avg_expenses,
                    AVG(EXTRACT(EPOCH FROM (t.end_time - t.start_time))/3600) as avg_duration,
                    COUNT(CASE WHEN t.status = 'completed' THEN 1 END) as completed_trips,
                    COUNT(CASE WHEN t.status != 'completed' THEN 1 END) as delayed_trips,
                    COUNT(DISTINCT t.vehicle_id) as vehicles_used,
                    COUNT(DISTINCT t.driver_id) as drivers_used
                FROM trips t
                JOIN routes r ON t.route_id = r.id
                JOIN financials f ON t.trip_id = f.trip_id
                WHERE t.start_time >= CURRENT_DATE - INTERVAL '30 days'
                GROUP BY r.name
            )
            SELECT 
                route,
                total_trips,
                avg_revenue,
                avg_profit,
                avg_expenses,
                avg_duration,
                completed_trips,
                delayed_trips,
                vehicles_used,
                drivers_used,
                -- Efficiency Score Calculation (weighted factors)
                (
                    (completed_trips::float / total_trips) * 0.3 + -- Completion Rate
                    (avg_profit / (SELECT MAX(avg_profit) FROM route_metrics)) * 0.3 + -- Profit Efficiency
                    (1 - (avg_duration / (SELECT MAX(avg_duration) FROM route_metrics))) * 0.2 + -- Time Efficiency
                    (vehicles_used::float / (SELECT MAX(vehicles_used) FROM route_metrics)) * 0.1 + -- Vehicle Utilization
                    (drivers_used::float / (SELECT MAX(drivers_used) FROM route_metrics)) * 0.1 -- Driver Utilization
                ) * 100 as efficiency_score
            FROM route_metrics
            ORDER BY efficiency_score DESC
        """;
        
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Map<String, Object> score = new HashMap<>();
                score.put("route", rs.getString("route"));
                score.put("totalTrips", rs.getInt("total_trips"));
                score.put("avgRevenue", rs.getDouble("avg_revenue"));
                score.put("avgProfit", rs.getDouble("avg_profit"));
                score.put("avgExpenses", rs.getDouble("avg_expenses"));
                score.put("avgDuration", rs.getDouble("avg_duration"));
                score.put("completedTrips", rs.getInt("completed_trips"));
                score.put("delayedTrips", rs.getInt("delayed_trips"));
                score.put("vehiclesUsed", rs.getInt("vehicles_used"));
                score.put("driversUsed", rs.getInt("drivers_used"));
                score.put("efficiencyScore", rs.getDouble("efficiency_score"));
                efficiencyScores.add(score);
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting route efficiency scores", ex);
        }
        return efficiencyScores;
    }

    public List<Map<String, Object>> getOptimalVehicleAllocation() {
        List<Map<String, Object>> allocations = new ArrayList<>();
        String sql = """
            WITH route_demand AS (
                SELECT 
                    r.name as route,
                    COUNT(*) as total_trips,
                    AVG(EXTRACT(EPOCH FROM (t.end_time - t.start_time))/3600) as avg_duration,
                    COUNT(DISTINCT t.vehicle_id) as vehicles_used,
                    AVG(f.revenue) as avg_revenue,
                    AVG(f.profit) as avg_profit
                FROM trips t
                JOIN routes r ON t.route_id = r.id
                JOIN financials f ON t.trip_id = f.trip_id
                WHERE t.start_time >= CURRENT_DATE - INTERVAL '30 days'
                GROUP BY r.name
            ),
            vehicle_stats AS (
                SELECT 
                    v.id,
                    v.capacity,
                    v.vehicle_model,
                    v.sacco,
                    COUNT(t.trip_id) as assigned_trips,
                    AVG(EXTRACT(EPOCH FROM (t.end_time - t.start_time))/3600) as avg_trip_duration,
                    AVG(f.revenue) as avg_revenue,
                    AVG(f.profit) as avg_profit
                FROM vehicle v
                LEFT JOIN trips t ON v.id = t.vehicle_id 
                    AND t.start_time >= CURRENT_DATE - INTERVAL '7 days'
                LEFT JOIN financials f ON t.trip_id = f.trip_id
                GROUP BY v.id, v.capacity, v.vehicle_model, v.sacco
            )
            SELECT 
                rd.route,
                rd.total_trips,
                rd.avg_duration,
                rd.vehicles_used,
                rd.avg_revenue,
                rd.avg_profit,
                CEIL(rd.total_trips * rd.avg_duration / 24) as required_vehicles,
                (SELECT AVG(capacity) FROM vehicle_stats) as avg_vehicle_capacity,
                (SELECT AVG(assigned_trips) FROM vehicle_stats) as avg_trips_per_vehicle,
                (SELECT AVG(avg_revenue) FROM vehicle_stats) as avg_vehicle_revenue,
                (SELECT AVG(avg_profit) FROM vehicle_stats) as avg_vehicle_profit
            FROM route_demand rd
            ORDER BY rd.total_trips DESC
        """;
        
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Map<String, Object> allocation = new HashMap<>();
                allocation.put("route", rs.getString("route"));
                allocation.put("totalTrips", rs.getInt("total_trips"));
                allocation.put("avgDuration", rs.getDouble("avg_duration"));
                allocation.put("vehiclesUsed", rs.getInt("vehicles_used"));
                allocation.put("avgRevenue", rs.getDouble("avg_revenue"));
                allocation.put("avgProfit", rs.getDouble("avg_profit"));
                allocation.put("requiredVehicles", rs.getInt("required_vehicles"));
                allocation.put("avgVehicleCapacity", rs.getInt("avg_vehicle_capacity"));
                allocation.put("avgTripsPerVehicle", rs.getDouble("avg_trips_per_vehicle"));
                allocation.put("avgVehicleRevenue", rs.getDouble("avg_vehicle_revenue"));
                allocation.put("avgVehicleProfit", rs.getDouble("avg_vehicle_profit"));
                allocations.add(allocation);
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting optimal vehicle allocation", ex);
        }
        return allocations;
    }

    public List<Map<String, Object>> getAdaptiveScheduleRecommendations() {
        List<Map<String, Object>> recommendations = new ArrayList<>();
        String sql = """
            WITH hourly_demand AS (
                SELECT 
                    r.name as route,
                    EXTRACT(HOUR FROM t.start_time) as hour_of_day,
                    COUNT(*) as trip_count,
                    AVG(f.revenue) as avg_revenue,
                    AVG(f.profit) as avg_profit,
                    COUNT(DISTINCT t.vehicle_id) as vehicles_used,
                    COUNT(DISTINCT t.driver_id) as drivers_used
                FROM trips t
                JOIN routes r ON t.route_id = r.id
                JOIN financials f ON t.trip_id = f.trip_id
                WHERE t.start_time >= CURRENT_DATE - INTERVAL '30 days'
                GROUP BY r.name, EXTRACT(HOUR FROM t.start_time)
            ),
            peak_hours AS (
                SELECT 
                    route,
                    hour_of_day,
                    trip_count,
                    avg_revenue,
                    avg_profit,
                    vehicles_used,
                    drivers_used,
                    RANK() OVER (PARTITION BY route ORDER BY trip_count DESC) as demand_rank
                FROM hourly_demand
            )
            SELECT 
                route,
                hour_of_day,
                trip_count,
                avg_revenue,
                avg_profit,
                vehicles_used,
                drivers_used,
                CASE 
                    WHEN demand_rank <= 3 THEN 'Peak'
                    WHEN demand_rank <= 6 THEN 'Moderate'
                    ELSE 'Low'
                END as demand_level,
                CASE 
                    WHEN demand_rank <= 3 THEN CEIL(trip_count * 1.2)
                    WHEN demand_rank <= 6 THEN trip_count
                    ELSE CEIL(trip_count * 0.8)
                END as recommended_trips
            FROM peak_hours
            WHERE demand_rank <= 8
            ORDER BY route, hour_of_day
        """;
        
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Map<String, Object> recommendation = new HashMap<>();
                recommendation.put("route", rs.getString("route"));
                recommendation.put("hourOfDay", rs.getInt("hour_of_day"));
                recommendation.put("tripCount", rs.getInt("trip_count"));
                recommendation.put("avgRevenue", rs.getDouble("avg_revenue"));
                recommendation.put("avgProfit", rs.getDouble("avg_profit"));
                recommendation.put("vehiclesUsed", rs.getInt("vehicles_used"));
                recommendation.put("driversUsed", rs.getInt("drivers_used"));
                recommendation.put("demandLevel", rs.getString("demand_level"));
                recommendation.put("recommendedTrips", rs.getInt("recommended_trips"));
                recommendations.add(recommendation);
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting adaptive schedule recommendations", ex);
        }
        return recommendations;
    }
} 