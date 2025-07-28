/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route;

import com.ignium.nganya.route.models.Route;
import com.ignium.nganya.route.models.RouteAssignment;
import java.sql.Date;
import java.util.List;
import java.util.Map;

/**
 *
 * @author olal
 */
public interface RouteDaoApi {

    boolean saveRoute(Route route);

    Route getRouteById(int id);

    List<Route> getAllRoutes(int offset, int pageSize);

    boolean updateRoute(Route route);

    boolean deleteRoute(int id);
    
    List<RouteAssignment> driverAssignments(String username);
    
    List<RouteAssignment> AllAssignments(Date start);
    
    public Map<String, Integer> routeKpi();
}
