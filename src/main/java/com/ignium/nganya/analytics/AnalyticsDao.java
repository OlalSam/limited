package com.ignium.nganya.analytics;

import jakarta.annotation.Resource;
import jakarta.ejb.Stateless;
import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.time.LocalDate;

@Stateless
public class AnalyticsDao  {
    private static final Logger logger = Logger.getLogger(AnalyticsDao.class.getName());
    
    @Resource(lookup = "java:global/nganya1")
    private DataSource dataSource;
    
    public void recordVehicleLocation(int driverId, int vehicleId, double latitude, double longitude, Timestamp timestamp) {
        String sql = "INSERT INTO vehicle_history ( driver_id, vehicle_id, latitude, longitude, timestamp) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            ps.setInt(2, vehicleId);
            ps.setDouble(3, latitude);
            ps.setDouble(4, longitude);
            ps.setTimestamp(5, timestamp);
            ps.executeUpdate();
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error recording vehicle location", ex);
        }
    }
    
    public List<Map<String, Object>> getVehicleHistory(int vehicleId, Timestamp startTime, Timestamp endTime) {
        List<Map<String, Object>> history = new ArrayList<>();
        String sql = "SELECT latitude, longitude, in_zone, timestamp FROM vehicle_history " +
                    "WHERE vehicle_id = ? AND timestamp BETWEEN ? AND ? ORDER BY timestamp";
                    
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            ps.setTimestamp(2, startTime);
            ps.setTimestamp(3, endTime);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> location = new HashMap<>();
                    location.put("driver", rs.getString("driver_id"));
                    location.put("latitude", rs.getDouble("latitude"));
                    location.put("longitude", rs.getDouble("longitude"));
                    location.put("timestamp", rs.getTimestamp("timestamp"));
                    history.add(location);
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error retrieving vehicle history", ex);
        }
        return history;
    }

    public void createTablesIfNotExist() {
        String createTripsTable = """
            CREATE TABLE IF NOT EXISTS trips (
                trip_id SERIAL PRIMARY KEY,
                driver_id INT NOT NULL,
                fare DECIMAL(10, 2) NOT NULL,
                route_id INT NOT NULL,
                start_time TIMESTAMP NOT NULL,
                end_time TIMESTAMP NOT NULL,
                FOREIGN KEY (driver_id) REFERENCES users(id),
                FOREIGN KEY (route_id) REFERENCES routes(id)
            )""";
            
        String createFinancialsTable = """
            CREATE TABLE IF NOT EXISTS financials (
                financial_id SERIAL PRIMARY KEY,
                trip_id INT NOT NULL,
                revenue DECIMAL(10, 2) NOT NULL,
                expenses DECIMAL(10, 2) NOT NULL,
                profit DECIMAL(10, 2) NOT NULL,
                FOREIGN KEY (trip_id) REFERENCES trips(trip_id)
            )""";

        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(createTripsTable);
            stmt.execute(createFinancialsTable);
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error creating analytics tables", ex);
        }
    }

    public void recordTrip(int driverId, String driverUsername, int vehicleId, double fare, int routeId, Timestamp startTime, Timestamp endTime, String status) {
        String sql = "INSERT INTO trips (driver_id, driver_username, vehicle_id, fare, route_id, start_time, end_time, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, driverId);
            ps.setString(2, driverUsername);
            ps.setInt(3, vehicleId);
            ps.setDouble(4, fare);
            ps.setInt(5, routeId);
            ps.setTimestamp(6, startTime);
            ps.setTimestamp(7, endTime);
            ps.setString(8, status);
            ps.executeUpdate();
            // Record financial data if needed
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    recordFinancials(rs.getInt(1), fare);
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error recording trip (all fields)", ex);
        }
    }

    private void recordFinancials(int tripId, double revenue) {
        String sql = "INSERT INTO financials (trip_id, revenue, expenses, profit) VALUES (?, ?, ?, ?)";
        double expenses = calculateExpenses(revenue); // Simplified calculation
        double profit = revenue - expenses;
        
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tripId);
            ps.setDouble(2, revenue);
            ps.setDouble(3, expenses);
            ps.setDouble(4, profit);
            ps.executeUpdate();
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error recording financials", ex);
        }
    }

    private double calculateExpenses(double revenue) {
        return revenue * 0.3; // Example: 30% operational costs
    }

    public List<Object> getRevenueData() {
    List<Object> revenueData = new ArrayList<>();
    String sql = """
        SELECT SUM(revenue) as daily_revenue 
        FROM financials f 
        JOIN trips t ON f.trip_id = t.trip_id 
        WHERE t.start_time >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY DATE(t.start_time)
        ORDER BY DATE(t.start_time)""";
        
    try (Connection conn = dataSource.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        while (rs.next()) {
            revenueData.add(rs.getDouble("daily_revenue"));
        }
    } catch (SQLException ex) {
        logger.log(Level.SEVERE, "Error getting revenue data", ex);
    }
    return revenueData;
}

public List<String> getRevenuePeriodLabels() {
    List<String> labels = new ArrayList<>();
    String sql = """
        SELECT DISTINCT DATE(start_time) as date
        FROM trips 
        WHERE start_time >= CURRENT_DATE - INTERVAL '30 days'
        ORDER BY date""";
        
    try (Connection conn = dataSource.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        while (rs.next()) {
            labels.add(rs.getDate("date").toString());
        }
    } catch (SQLException ex) {
        logger.log(Level.SEVERE, "Error getting revenue period labels", ex);
    }
    return labels;
}

public Map<String, Integer> getTripDistribution() {
    Map<String, Integer> distribution = new HashMap<>();
    String sql = """
        SELECT r.name, COUNT(*) as trip_count 
        FROM trips t 
        JOIN routes r ON t.route_id = r.id 
        WHERE t.start_time >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY r.name""";
        
    try (Connection conn = dataSource.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        while (rs.next()) {
            distribution.put(rs.getString("name"), rs.getInt("trip_count"));
        }
    } catch (SQLException ex) {
        logger.log(Level.SEVERE, "Error getting trip distribution", ex);
    }
    return distribution;
}

public List<Number> getRoutePerformanceData() {
    List<Number> performanceData = new ArrayList<>();
    String sql = """
        SELECT AVG(f.revenue) as avg_revenue 
        FROM financials f 
        JOIN trips t ON f.trip_id = t.trip_id 
        JOIN routes r ON t.route_id = r.id 
        WHERE t.start_time >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY r.name
        ORDER BY r.name""";
        
    try (Connection conn = dataSource.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        while (rs.next()) {
            performanceData.add(rs.getDouble("avg_revenue"));
        }
    } catch (SQLException ex) {
        logger.log(Level.SEVERE, "Error getting route performance data", ex);
    }
    return performanceData;
}

public List<String> getRouteNames() {
    List<String> routeNames = new ArrayList<>();
    String sql = "SELECT DISTINCT name FROM routes ORDER BY name";
        
    try (Connection conn = dataSource.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        while (rs.next()) {
            routeNames.add(rs.getString("name"));
        }
    } catch (SQLException ex) {
        logger.log(Level.SEVERE, "Error getting route names", ex);
    }
    return routeNames;
}

public Map<String, Double> calculateGrowthRates() {
    Map<String, Double> growth = new HashMap<>();
    String sql = """
        WITH current_month AS (
            SELECT COUNT(*) as trips, SUM(f.revenue) as revenue, AVG(f.revenue) as avg_revenue, SUM(f.profit) as profit
            FROM trips t JOIN financials f ON t.trip_id = f.trip_id
            WHERE t.start_time >= CURRENT_DATE - INTERVAL '30 days'
        ),
        previous_month AS (
            SELECT COUNT(*) as trips, SUM(f.revenue) as revenue, AVG(f.revenue) as avg_revenue, SUM(f.profit) as profit
            FROM trips t JOIN financials f ON t.trip_id = f.trip_id
            WHERE t.start_time >= CURRENT_DATE - INTERVAL '60 days' AND t.start_time < CURRENT_DATE - INTERVAL '30 days'
        )
        SELECT 
            ((c.revenue - p.revenue) / NULLIF(p.revenue, 0)) * 100 as revenue_growth,
            ((c.trips - p.trips) / NULLIF(p.trips, 0)) * 100 as trips_growth,
            ((c.avg_revenue - p.avg_revenue) / NULLIF(p.avg_revenue, 0)) * 100 as avg_revenue_growth,
            ((c.profit - p.profit) / NULLIF(p.profit, 0)) * 100 as profit_growth
        FROM current_month c, previous_month p""";
        
    try (Connection conn = dataSource.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        if (rs.next()) {
            growth.put("revenue", rs.getDouble("revenue_growth"));
            growth.put("trips", rs.getDouble("trips_growth"));
            growth.put("avgRevenue", rs.getDouble("avg_revenue_growth"));
            growth.put("profit", rs.getDouble("profit_growth"));
        }
    } catch (SQLException ex) {
        logger.log(Level.SEVERE, "Error calculating growth rates", ex);
    }
    return growth;
}

public List<DetailedAnalytic> getDetailedAnalytics() {
    List<DetailedAnalytic> analytics = new ArrayList<>();
    String sql = """
        SELECT DATE(t.start_time) as date, r.name as route, 
               COUNT(*) as trips, SUM(f.revenue) as revenue, SUM(f.profit) as profit
        FROM trips t 
        JOIN routes r ON t.route_id = r.id
        JOIN financials f ON t.trip_id = f.trip_id
        WHERE t.start_time >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY DATE(t.start_time), r.name
        ORDER BY date DESC, route""";
        
    try (Connection conn = dataSource.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        while (rs.next()) {
            DetailedAnalytic analytic = new DetailedAnalytic();
            analytic.setDate(rs.getDate("date"));
            analytic.setRoute(rs.getString("route"));
            analytic.setTrips(rs.getInt("trips"));
            analytic.setRevenue(rs.getDouble("revenue"));
            analytic.setProfit(rs.getDouble("profit"));
            analytics.add(analytic);
        }
    } catch (SQLException ex) {
        logger.log(Level.SEVERE, "Error getting detailed analytics", ex);
    }
    return analytics;
}

public Map<String, Object> getAnalyticsSummary() {
        Map<String, Object> summary = new HashMap<>();
        String sql = """
            SELECT 
                COUNT(*) as total_trips,
                SUM(f.revenue) as total_revenue,
                SUM(f.profit) as total_profit,
                AVG(f.revenue) as avg_revenue_per_trip
            FROM trips t
            JOIN financials f ON t.trip_id = f.trip_id
            WHERE t.start_time >= CURRENT_DATE - INTERVAL '30 days'""";
        
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                summary.put("totalTrips", rs.getInt("total_trips"));
                summary.put("totalRevenue", rs.getDouble("total_revenue"));
                summary.put("totalProfit", rs.getDouble("total_profit"));
                summary.put("avgRevenuePerTrip", rs.getDouble("avg_revenue_per_trip"));
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting analytics summary", ex);
        }
        return summary;
    }

    public double getHoursWorkedToday(String username) {
        String sql = "SELECT COALESCE(EXTRACT(EPOCH FROM SUM(end_time - start_time))/3600, 0) as hours FROM trips WHERE driver_username = ? AND DATE(start_time) = CURRENT_DATE AND end_time IS NOT NULL";
        try (var conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("hours");
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error calculating hours worked", ex);
        }
        return 0.0;
    }

    public Map<String, Object> getWeeklyTripHistory(LocalDate weekStart) {
        Map<String, Object> weeklyData = new HashMap<>();
        // Calculate the previous week's start and end dates
        LocalDate previousWeekStart = weekStart.minusDays(7);
        LocalDate previousWeekEnd = previousWeekStart.plusDays(6);
        
        String sql = """
            SELECT 
                DATE(t.start_time) as trip_date,
                COUNT(*) as total_trips,
                SUM(f.revenue) as daily_revenue,
                SUM(f.profit) as daily_profit,
                COUNT(DISTINCT t.driver_id) as active_drivers,
                COUNT(DISTINCT t.vehicle_id) as active_vehicles,
                AVG(EXTRACT(EPOCH FROM (t.end_time - t.start_time))/3600) as avg_trip_duration
            FROM trips t
            JOIN financials f ON t.trip_id = f.trip_id
            WHERE t.start_time >= ?::timestamp AND t.start_time < (?::timestamp + INTERVAL '1 day')
            GROUP BY DATE(t.start_time)
            ORDER BY trip_date""";
            
        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(previousWeekStart));
            ps.setDate(2, java.sql.Date.valueOf(previousWeekEnd));
            
            List<Map<String, Object>> dailyStats = new ArrayList<>();
            double totalRevenue = 0;
            int totalTrips = 0;
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> dayStats = new HashMap<>();
                    dayStats.put("date", rs.getDate("trip_date"));
                    dayStats.put("trips", rs.getInt("total_trips"));
                    dayStats.put("revenue", rs.getDouble("daily_revenue"));
                    dayStats.put("profit", rs.getDouble("daily_profit"));
                    dayStats.put("activeDrivers", rs.getInt("active_drivers"));
                    dayStats.put("activeVehicles", rs.getInt("active_vehicles"));
                    dayStats.put("avgTripDuration", rs.getDouble("avg_trip_duration"));
                    
                    dailyStats.add(dayStats);
                    totalRevenue += rs.getDouble("daily_revenue");
                    totalTrips += rs.getInt("total_trips");
                }
            }
            
            weeklyData.put("dailyStats", dailyStats);
            weeklyData.put("totalRevenue", totalRevenue);
            weeklyData.put("totalTrips", totalTrips);
            weeklyData.put("weekStart", previousWeekStart);
            weeklyData.put("weekEnd", previousWeekEnd);
            
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting weekly trip history", ex);
        }
        
        return weeklyData;
    }
}
