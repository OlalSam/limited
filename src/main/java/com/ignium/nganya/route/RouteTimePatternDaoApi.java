/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route;

import com.ignium.nganya.route.models.RouteTimePattern;
import java.util.List;

/**
 *
 * @author olal
 */
public interface RouteTimePatternDaoApi {

    boolean saveTimePattern(RouteTimePattern pattern);

    RouteTimePattern getTimePatternById(int id);

    List<RouteTimePattern> getPatternsForRoute(int routeId);

    boolean updateTimePattern(RouteTimePattern pattern);

    boolean deleteTimePattern(int id);
}
