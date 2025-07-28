/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.service;


import com.ignium.nganya.route.RouteDaoApi;
import com.ignium.nganya.route.models.Route;
import com.ignium.nganya.route.models.RouteAssignment;
import jakarta.ejb.Stateless;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.io.Serializable;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

import java.util.Optional;

/**
 * Service layer for route-related operations.
 * This class handles business logic for route management.
 */
@Stateless
public class RouteService implements Serializable{

    @Inject
    private RouteDaoApi routeDao;    
        
    /**
     * Creates a new route.
     *
     * @param route the route to create
     * @return true if creation was successful, false otherwise
     */
    @Transactional
    public boolean createRoute(Route route) {
        // Validate route data
        if (route == null || route.getName() == null || route.getName().isBlank()
                || route.getOriginStage() == null || route.getDestinationStage() == null
                || route.getStages() == null || route.getStages().isEmpty()) {
            return false;
        }

        return routeDao.saveRoute(route);
    }

    /**
     * Retrieves a route by its ID.
     *
     * @param id the route ID
     * @return Optional containing the route if it exists
     */
    public Optional<Route> getRouteById(int id) {
        if (id <= 0) {
            return Optional.empty();
        }

        Route route = routeDao.getRouteById(id);
        return Optional.ofNullable(route);
    }

    /**
     * Lists all routes with pagination.
     *
     * @param page the page number (starting from 0)
     * @param pageSize the number of items per page
     * @return list of routes for the specified page
     */
    public List<Route> listRoutes(int page, int pageSize) {
        if (page < 0) {
            page = 0;
        }

        if (pageSize <= 0) {
            pageSize = 10; // Default page size
        }

        int offset = page * pageSize;
        return routeDao.getAllRoutes(offset, pageSize);
    }

    /**
     * Updates an existing route.
     *
     * @param route the route with updated information
     * @return true if update was successful, false otherwise
     */
    @Transactional
    public boolean updateRoute(Route route) {
        if (route == null || route.getId() <= 0 || route.getName() == null
                || route.getName().isBlank() || route.getOriginStage() == null
                || route.getDestinationStage() == null || route.getStages() == null
                || route.getStages().isEmpty()) {
            return false;
        }

        // Check if route exists
        Route existingRoute = routeDao.getRouteById(route.getId());
        if (existingRoute == null) {
            return false;
        }

        return routeDao.updateRoute(route);
    }

    /**
     * Deletes a route by its ID.
     *
     * @param id the route ID to delete
     * @return true if deletion was successful, false otherwise
     */
    @Transactional
    public boolean deleteRoute(int id) {
        if (id <= 0) {
            return false;
        }

        // Check if route exists before deleting
        Route existingRoute = routeDao.getRouteById(id);
        if (existingRoute == null) {
            return false;
        }

        return routeDao.deleteRoute(id);
    }

    /**
     * Retrieves assignments for a specific driver.
     *
     * @param username the driver's username
     * @return list of assignments for the driver
     */
    public List<RouteAssignment> getDriverAssignments(String username) {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("Username cannot be null or empty");
        }

        return routeDao.driverAssignments(username);
    }

    /**
     * Retrieves all route assignments from a specified date.
     *
     * @param startDate the starting date for assignments
     * @return list of all assignments from the start date
     */
    public List<RouteAssignment> getAllAssignments(LocalDate startDate) {
        if (startDate == null) {
            startDate = LocalDate.now(); // Default to current date
        }

        return routeDao.AllAssignments(Date.valueOf(startDate));
    }
}
