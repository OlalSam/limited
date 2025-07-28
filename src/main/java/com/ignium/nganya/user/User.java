package com.ignium.nganya.user;

public class User {

    private int userId;
    private String username;
    private String firstName;
    private String secondName;
    private String password;
    private String email;
    private String phoneNumber;
    private String driverLicence;
    private String status;
    private Role role;

    // Default constructor
    public User() {
    }

    public User(int userId, String username) {
        this.userId = userId;
        this.username = username;
    }

    
    // Original constructors
    public User(String username, String password, Role role) {
        this.username = username;
        this.password = password;
        this.role = role;
    }

    public User(String username, String password, String email, Role role) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.role = role;
    }

    public User(int userId, String username, String firstName, String secondName, String password, String email, Role role) {
        this.userId = userId;
        this.username = username;
        this.firstName = firstName;
        this.secondName = secondName;
        this.password = password;
        this.email = email;
        this.role = role;
    }

    // New constructors including phoneNumber, driverLicence, and status
    // Constructor without userId, firstName, secondName
    public User(String username, String password, String email, Role role, String phoneNumber, String driverLicence, String status) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.role = role;
        this.phoneNumber = phoneNumber;
        this.driverLicence = driverLicence;
        this.status = status;
    }

    public User(int userId, String username, String firstName, String secondName, String password, String email, Role role, String phoneNumber, String driverLicence, String status) {
        this.userId = userId;
        this.username = username;
        this.firstName = firstName;
        this.secondName = secondName;
        this.password = password;
        this.email = email;
        this.role = role;
        this.phoneNumber = phoneNumber;
        this.driverLicence = driverLicence;
        this.status = status;
    }

    // Full constructor with all fields
    public User(int userId, String username, String firstName, String secondName, String email, Role role, String phoneNumber, String driverLicence, String status) {
        this.userId = userId;
        this.username = username;
        this.firstName = firstName;
        this.secondName = secondName;
        this.email = email;
        this.role = role;
        this.phoneNumber = phoneNumber;
        this.driverLicence = driverLicence;
        this.status = status;
    }

    // Getters and Setters
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getSecondName() {
        return secondName;
    }

    public void setSecondName(String secondName) {
        this.secondName = secondName;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getDriverLicence() {
        return driverLicence;
    }

    public void setDriverLicence(String driverLicence) {
        this.driverLicence = driverLicence;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    // Retaining the existing getGroup/setGroup for role management
    public Role getGroup() {
        return role;
    }

    public void setGroup(Role role) {
        this.role = role;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    @Override
    public int hashCode() {
        int hash = 7;
        hash = 41 * hash + this.userId;
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final User other = (User) obj;
        return this.userId == other.userId;
    }
}
