/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.service;


import com.ignium.nganya.route.models.Route;
import com.ignium.nganya.route.models.RouteAssignment;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Service interface defining operations for route management.
 */
public interface RouteServiceApi {
    
    /**
     * Creates a new route.
     *
     * @param route the route to create
     * @return true if creation was successful, false otherwise
     */
    boolean createRoute(Route route);
    
    /**
     * Retrieves a route by its ID.
     *
     * @param id the route ID
     * @return Optional containing the route if it exists
     */
    Optional<Route> getRouteById(int id);
    
    /**
     * Lists all routes with pagination.
     *
     * @param page the page number (starting from 0)
     * @param pageSize the number of items per page
     * @return list of routes for the specified page
     */
    List<Route> listRoutes(int page, int pageSize);
    
    /**
     * Updates an existing route.
     *
     * @param route the route with updated information
     * @return true if update was successful, false otherwise
     */
    boolean updateRoute(Route route);
    
    /**
     * Deletes a route by its ID.
     *
     * @param id the route ID to delete
     * @return true if deletion was successful, false otherwise
     */
    boolean deleteRoute(int id);
    
    /**
     * Retrieves assignments for a specific driver.
     *
     * @param username the driver's username
     * @return list of assignments for the driver
     */
    List<RouteAssignment> getDriverAssignments(String username);
    
    /**
     * Retrieves all route assignments from a specified date.
     *
     * @param startDate the starting date for assignments
     * @return list of all assignments from the start date
     */
    List<RouteAssignment> getAllAssignments(LocalDate startDate);
}