package com.ignium.nganya.route;

import java.util.*;

// ----- DAO Interfaces -----
public interface RouteKpiDaoApi {

    boolean saveRouteKpi(RouteKpi kpi);

    RouteKpi getRouteKpiById(int id);

    List<RouteKpi> getLatestKpis(int routeId, int limit);

    boolean updateRouteKpi(RouteKpi kpi);

    boolean deleteRouteKpi(int id);
}
