/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.route.service;

import com.ignium.nganya.MessageUtility;
import com.ignium.nganya.route.RouteDao;
import com.ignium.nganya.route.models.Route;
import com.ignium.nganya.route.models.RouteAssignment;
import com.ignium.nganya.route.models.Stage;
import com.ignium.nganya.route.models.TimeRange;
import jakarta.faces.context.Flash;
import jakarta.annotation.PostConstruct;
import jakarta.faces.application.FacesMessage;
import jakarta.faces.context.FacesContext;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import jakarta.security.enterprise.SecurityContext;

import org.primefaces.model.LazyDataModel;
import org.primefaces.model.SortOrder;

import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.primefaces.model.FilterMeta;
import org.primefaces.model.SortMeta;

/**
 *
 * @author olal
 */
@Named("routeController")
@ViewScoped
public class RouteController implements Serializable {

    private List<Route> datasource;
    private Route selected;
    private Route newRoute;

    private static final long serialVersionUID = 1L;

    @Inject
    private RouteService routeService;

    @Inject
    private SecurityContext securityContext;

    private LazyDataModel<Route> routes;
    private Route selectedRoute;
    private List<RouteAssignment> routeAssignments;
    private List<Stage> stages;
    private String userRole;

    
    @PostConstruct
    public void init() {
        userRole = securityContext.isCallerInRole("DRIVER") ? "DRIVER" : "ADMIN";
        selectedRoute = new Route();
        newRoute = new Route();
        stages = new ArrayList<>();

        // Initialize LazyDataModel for paginated route loading
        routes = new LazyDataModel<Route>() {
            
            @Override
            public int count(Map<String, FilterMeta> map) {
                return 0;
            }

            @Override
            public List<Route> load(int offset, int pageSize, Map<String, SortMeta> sortBy, Map<String, FilterMeta> filters) {
                int page = offset / pageSize;
                List<Route> results = routeService.listRoutes(offset, pageSize);
                // Set count
                setRowCount(results.size() > 0 ? results.size() + (page * pageSize) + 1 : 0);
                return results;
            }
        };

        // Initialize assignments
        loadAssignments();
    }

    /**
     * Loads route assignments based on user role.
     */
    private void loadAssignments() {
        if ("DRIVER".equals(userRole)) {
            String username = securityContext.getCallerPrincipal().getName();
            routeAssignments = routeService.getDriverAssignments(username);
        } else {
            routeAssignments = routeService.getAllAssignments(LocalDate.now());
        }
    }
    
    

    /**
     * Adds a new stage to the route being created or edited.
     */
    public void addStage() {
        Stage stage = new Stage();
        if (selectedRoute.getId() > 0) {
            selectedRoute.getStages().add(stage);
        } else {
            if (stages == null) {
                stages = new ArrayList<>();
            }
            stages.add(stage);
        }
    }

    /**
     * Removes a stage from the route being created or edited.
     *
     * @param stage the stage to remove
     */
    public void removeStage(Stage stage) {
        if (selectedRoute.getId() > 0) {
            selectedRoute.getStages().remove(stage);
        } else {
            stages.remove(stage);
        }
    }

    /**
     * Creates a new route.
     *
     * @return navigation outcome
     */
    public String createRoute() {
        newRoute.setStages(stages);

        boolean success = routeService.createRoute(newRoute);

        if (success) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_INFO, "Success", "Route created successfully"));

            // Reset form
            newRoute = new Route();
            stages = new ArrayList<>();

            return "/admin/routes?faces-redirect=true";
        } else {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Failed to create route"));
            return null;
        }
    }

    /**
     * Updates an existing route.
     */
    public void updateRoute() {
        boolean success = routeService.updateRoute(selectedRoute);

        if (success) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_INFO, "Success", "Route updated successfully"));
        } else {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Failed to update route"));
        }
    }

    /**
     * Prepares for editing a route.
     *
     * @param routeId the ID of the route to edit
     */
    public void editRoute(int routeId) {
        Optional<Route> routeOpt = routeService.getRouteById(routeId);
        if (routeOpt.isPresent()) {
            selectedRoute = routeOpt.get();
        } else {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Route not found"));
        }
    }

    /**
     * Deletes a route.
     *
     * @param route the route to delete
     */
    public void deleteRoute(Route route) {
        boolean success = routeService.deleteRoute(route.getId());

        if (success) {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_INFO, "Success", "Route deleted successfully"));
        } else {
            FacesContext.getCurrentInstance().addMessage(null,
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Failed to delete route"));
        }
    }

    /**
     * Refreshes route assignments data.
     */
    public void refreshAssignments() {
        loadAssignments();
    }

    // Getters and Setters
    public LazyDataModel<Route> getRoutes() {
        return routes;
    }

    public void setRoutes(LazyDataModel<Route> routes) {
        this.routes = routes;
    }

    public Route getSelectedRoute() {
        return selectedRoute;
    }

    public void setSelectedRoute(Route selectedRoute) {
        this.selectedRoute = selectedRoute;
    }

    public Route getNewRoute() {
        return newRoute;
    }

    public void setNewRoute(Route newRoute) {
        this.newRoute = newRoute;
    }

    public List<RouteAssignment> getRouteAssignments() {
        return routeAssignments;
    }

    public void setRouteAssignments(List<RouteAssignment> routeAssignments) {
        this.routeAssignments = routeAssignments;
    }

    public List<Stage> getStages() {
        return stages;
    }

    public void setStages(List<Stage> stages) {
        this.stages = stages;
    }

    public String getUserRole() {
        return userRole;
    }

    public Route getSelected() {
        return selected;
    }

    public void setSelected(Route selected) {
        this.selected = selected;
    }

    
}
