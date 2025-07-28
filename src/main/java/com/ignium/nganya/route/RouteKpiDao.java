package com.ignium.nganya.route;

import com.ignium.nganya.route.models.ListOfStageType;
import com.ignium.nganya.route.models.MapOfMetrics;
import jakarta.annotation.Resource;
import jakarta.enterprise.inject.Default;
import jakarta.inject.Inject;
import jakarta.json.bind.Jsonb;
import java.lang.reflect.Type;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.temporal.ChronoField;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.sql.DataSource;

/**
 *
 * @author olal
 */
@Default
public class RouteKpiDao implements RouteKpiDaoApi {

    @Resource(lookup = "java:global/nganya1")
    private DataSource dataSource;

    @Inject
    private Jsonb jsonb;

    private static final Type STAGE_MAP_TYPE = new MapOfMetrics();

    @Override
    public boolean saveRouteKpi(RouteKpi kpi) {
        String sql = "INSERT INTO route_kpis (route_id, metric_at, headway_target_s, on_time_perf_pct, avg_speed_kmh, load_factor_pct, extra_metrics) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, kpi.getRouteId());
            ps.setString(2, kpi.getMetricAt().toString());
            ps.setInt(3, kpi.getHeadwayTargetSeconds());
            ps.setDouble(4, kpi.getOnTimePerformancePct());
            ps.setObject(5, kpi.getAvgSpeedKmh());
            ps.setObject(6, kpi.getLoadFactorPct());
            ps.setString(7, jsonb.toJson(kpi.getExtraMetrics()));
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public RouteKpi getRouteKpiById(int id) {
        String sql = "SELECT * FROM route_kpis WHERE id = ?";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RouteKpi k = new RouteKpi();
                    k.setId(rs.getInt("id"));
                    k.setRouteId(rs.getInt("route_id"));
                    k.setMetricAt(parseCreatedAt(rs.getString("metric_at")));
                    k.setHeadwayTargetSeconds(rs.getInt("headway_target_s"));
                    k.setOnTimePerformancePct(rs.getDouble("on_time_perf_pct"));
                    k.setAvgSpeedKmh((Double) rs.getObject("avg_speed_kmh"));
                    k.setLoadFactorPct((Double) rs.getObject("load_factor_pct"));
                    k.setExtraMetrics(MapOfMetrics.deserializeMetrics(rs.getString("extra_metrics")));
                    return k;
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return null;
    }

    @Override
    public List<RouteKpi> getLatestKpis(int routeId, int limit) {
        List<RouteKpi> list = new ArrayList<>();
        String sql = "SELECT * FROM route_kpis WHERE route_id = ? ORDER BY metric_at DESC LIMIT ?";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, routeId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RouteKpi k = new RouteKpi();
                    k.setId(rs.getInt("id"));
                    k.setRouteId(rs.getInt("route_id"));
                    k.setMetricAt(parseCreatedAt(rs.getString("metric_at")));
                    k.setHeadwayTargetSeconds(rs.getInt("headway_target_s"));
                    k.setOnTimePerformancePct(rs.getDouble("on_time_perf_pct"));
                    k.setAvgSpeedKmh((Double) rs.getObject("avg_speed_kmh"));
                    k.setLoadFactorPct((Double) rs.getObject("load_factor_pct"));
                    k.setExtraMetrics(MapOfMetrics.deserializeMetrics(rs.getString("extra_metrics")));
                    list.add(k);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean updateRouteKpi(RouteKpi kpi) {
        String sql = "UPDATE route_kpis SET headway_target_s=?, on_time_perf_pct=?, avg_speed_kmh=?, load_factor_pct=?, extra_metrics=? WHERE id = ?";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, kpi.getHeadwayTargetSeconds());
            ps.setDouble(2, kpi.getOnTimePerformancePct());
            ps.setObject(3, kpi.getAvgSpeedKmh());
            ps.setObject(4, kpi.getLoadFactorPct());
            ps.setString(5, jsonb.toJson(kpi.getExtraMetrics()));
            ps.setInt(6, kpi.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteRouteKpi(int id) {
        String sql = "DELETE FROM route_kpis WHERE id = ?";
        try (var conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        }
    }
    
    private ZonedDateTime parseCreatedAt(String createdAt) {
        if (createdAt == null || createdAt.isBlank()) {
            return null;
        }
        DateTimeFormatter formatter = new DateTimeFormatterBuilder()
                .appendPattern("yyyy-MM-dd HH:mm:ss")
                .optionalStart()
                .appendFraction(ChronoField.NANO_OF_SECOND, 0, 9, true)
                .optionalEnd()
                .appendPattern("X")
                .toFormatter();
        return ZonedDateTime.parse(createdAt, formatter);
    }
}
