/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.controller;

import com.ignium.nganya.driver.Driver;
import com.ignium.nganya.driver.DriverDao;
import com.ignium.nganya.route.models.DriverProfileDto;
import com.ignium.nganya.schedule.Assignment;
import com.ignium.nganya.schedule.ScheduleDao;
import jakarta.inject.Inject;
import jakarta.security.enterprise.SecurityContext;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

/**
 *
 * @author olal
 */
@Path("/driverProfile")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class DriverProfile {

    @Inject
    private SecurityContext securityContext;

    @Inject
    private DriverDao emplService;

    @Inject
    private ScheduleDao scheduleDao;

    /**
     * GET /profile/driverDetails
     *
     * Returns the profile of the currently authenticated user.
     */
    @GET
    @Path("/driverDetails")
    public Response getMyProfile() {
        // obtain the logged-in username via Jakarta SecurityContext
        String username = securityContext.getCallerPrincipal().getName();
        Driver driver = emplService.getDriverByUsername(username);
        if (driver == null) {
            return Response
                    .status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"User not found\"}")
                    .build();
        }

        Assignment va  = scheduleDao.findActiveDriverAssignments(driver.getUserId());

        // Build and return the profile DTO
        DriverProfileDto dto = new DriverProfileDto(
                driver.getUserId(),
                driver.getUsername(),
                driver.getFirstName(),
                driver.getSecondName(),
                va  != null ? va.getVehiclePlate() : null,
                va  != null ? va.getVehicleModel() : null
        );
        return Response.ok(dto).build();
    }

    /**
     * GET /profile/driverDetails/{username}
     *
     * Returns the profile for any driver by username.
     *
     * @param username
     * @return
     */
    @GET
    @Path("/driverDetails/{username}")
    public Response getProfileByUsername(@PathParam("username") String username) {
        Driver driver = emplService.getDriverByUsername(username);

        if (driver == null) {
            return Response
                    .status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"User not found\"}")
                    .build();
        }

        Assignment va  = scheduleDao.findActiveDriverAssignments(driver.getUserId());

        // Build and return the profile DTO
        DriverProfileDto dto = new DriverProfileDto(
                driver.getUserId(),
                driver.getUsername(),
                driver.getFirstName(),
                driver.getSecondName(),
                va  != null ? va.getVehiclePlate() : null,
                va  != null ? va.getVehicleModel() : null
        );
        return Response.ok(dto).build();
    }

}
