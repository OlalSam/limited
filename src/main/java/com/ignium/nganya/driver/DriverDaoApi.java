/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.driver;

import java.util.List;
import java.util.Map;

/**
 *
 * @author olal
 */
public interface DriverDaoApi {

    // Create a new driver
    boolean saveDriver(Driver driver);

    // Read (Get) a driver by ID
    Driver getDriverById(int driverId);
    
    Driver getDriverByUsername(String username);

    // Read (Get) all drivers
    List<Driver> getAllDrivers(int offset, int pageSize);

    // Update a driver's details
    boolean updateDriver(Driver driver);

    // Delete a driver by ID
    boolean deleteDriver(int driverId);

    public Map<String, Integer> driverKpi();

    }
