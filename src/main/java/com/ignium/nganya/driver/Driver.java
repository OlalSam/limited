/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.ignium.nganya.driver;

import com.ignium.nganya.user.Role;
import com.ignium.nganya.user.User;

/**
 *
 * @author olal
 */
public class Driver extends User {

    // Default constructor
    public Driver() {
        super();
    }

    // Constructor for creating a driver without an ID (before persistence)
    public Driver(String username, String password, String email, Role role,
            String phoneNumber, String driverLicence, String status) {
        super(username, password, email, role, phoneNumber, driverLicence, status);
    }

    // Full constructor including userId and other fields
    public Driver(int userId, String username, String firstName, String secondName, String password,
            String email, Role role, String phoneNumber, String driverLicence, String status) {
        super(userId, username, firstName, secondName, password, email, role, phoneNumber, driverLicence, status);
    }

    public Driver(int userId, String username, String firstName, String secondName, 
            String email, Role role, String phoneNumber, String driverLicence, String status){
        super(userId, username, firstName, secondName, email, role, phoneNumber, driverLicence, status );
    }

    public Driver(int userId, String username) {
        super(userId, username);
    }

    

}
