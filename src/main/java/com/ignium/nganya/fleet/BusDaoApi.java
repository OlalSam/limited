/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.fleet;

import java.util.List;
import java.util.Map;

/**
 *
 * @author olal
 */
public interface BusDaoApi {
    boolean save(Vehicle vehicle); // Create

    Vehicle findByPlateNumber(String plateNumber); // Read

    List<Vehicle> findAll(int offset, int pageSize); // Read all

    boolean update(Vehicle vehicle); // Update

    boolean delete(String plateNumber); // Delete
    
    Map<String, Integer> fleetKpi();
    
    int getVehicleFuelLevel(String plateNumber);
    
    int getVehicleHealth(String plateNumber);
    
    String getAssignedVehicle(String username);
}
