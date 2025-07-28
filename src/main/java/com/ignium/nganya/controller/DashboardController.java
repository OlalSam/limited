/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.controller;

import com.ignium.nganya.driver.DriverDaoApi;
import com.ignium.nganya.fleet.BusDaoApi;
import com.ignium.nganya.route.RouteDaoApi;
import jakarta.annotation.PostConstruct;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import jakarta.security.enterprise.SecurityContext;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

/**
 *
 * @author olal
 */
@Named("dashboard")
@ViewScoped
public class DashboardController implements Serializable {

    @Inject
    private SecurityContext context;

    @Inject
    private DriverDaoApi driverService;

    @Inject
    private BusDaoApi fleetService;
    
    @Inject
    private RouteDaoApi routeService;
    
    private Integer totalRoutes;

    private String userRole;
    private String userName;

    private Map<String, Integer> driverKpi;
    private Map<String, Integer> fleetKpi;
    private Map<String, Integer> routeKpi;

    private Integer totalDrivers;
    private Integer availableDrivers;

    private Integer totalVehicles;
    private Integer availablvehicles;

    @PostConstruct
    public void init() {
        userRole = context.isCallerInRole("DRIVER") ? "DRIVER" : "ADMIN";
        driverKpi = new HashMap<>();
        driverKpi = driverService.driverKpi();
        fleetKpi = new HashMap<>();
        fleetKpi = fleetService.fleetKpi();
        routeKpi = new HashMap<>();
        routeKpi = routeService.routeKpi();

    }

    public Integer getTotalRoutes() {
        totalRoutes = routeKpi.getOrDefault("totalRoutes", 0);
        return totalRoutes;
    }

    
    public Integer getTotalVehicles() {
        totalVehicles = fleetKpi.getOrDefault("totalVehicles", totalVehicles);
        return totalVehicles;
    }

    public Integer getAvailablvehicles() {
        availablvehicles = fleetKpi.getOrDefault("totalVehicles", availablvehicles);
        return availablvehicles;
    }

    public Integer getTotalDrivers() {
        totalDrivers = driverKpi.getOrDefault("totalDrivers", 0);
        return totalDrivers;
    }

    public Integer getAvailableDrivers() {
        availableDrivers = driverKpi.getOrDefault("availableDrivers", 0);
        return availableDrivers;
    }

    public String getUserRole() {
        return userRole;
    }

    public String getUserName() {
        userName = context.getCallerPrincipal().getName();
        return userName;
    }

}
