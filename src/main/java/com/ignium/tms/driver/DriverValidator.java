package com.ignium.tms.driver;

import jakarta.faces.application.FacesMessage;
import jakarta.faces.component.UIComponent;
import jakarta.faces.context.FacesContext;
import jakarta.faces.validator.FacesValidator;
import jakarta.faces.validator.Validator;
import jakarta.faces.validator.ValidatorException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.naming.InitialContext;

@FacesValidator("driverValidator")
public class DriverValidator implements Validator<String> {

    private static final String USERNAME_PATTERN = "^[a-zA-Z0-9_]{4,}$";
    private static final String EMAIL_PATTERN = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
    private static final String PHONE_PATTERN = "^[0-9]{10,15}$";
    private static final String LICENCE_PATTERN = "^[A-Za-z0-9-]{5,}$";   
    
    private DataSource dataSource;

    public DriverValidator() {
        try {
            InitialContext ctx = new InitialContext();
            dataSource = (DataSource) ctx.lookup("java:global/nganya1");
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize data source", e);
        }
    }

    @Override
    public void validate(FacesContext context, UIComponent component, String value) throws ValidatorException {
        if (value == null || value.trim().isEmpty()) {
            return; // Let required validator handle empty values
        }

        String fieldName = (String) component.getAttributes().get("fieldName");
        Object userIdObj = component.getAttributes().get("userId");
        String role = (String) component.getAttributes().get("role");

        if (fieldName == null) return;

        // Uniqueness check
        if (isUniqueField(fieldName) && fieldExists(fieldName, value, userIdObj)) {
            throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                getFieldLabel(fieldName) + " already exists. Please choose a different one.", null));
        }

        // Field-specific validation
        switch (fieldName) {
            case "username":
                if (!value.matches(USERNAME_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Username must be at least 4 characters and contain only letters, numbers, and underscores.", null));
                }
                break;
            case "email":
                if (!value.matches(EMAIL_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Please enter a valid email address.", null));
                }
                break;
            case "phone_number":
                if (!value.matches(PHONE_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Phone number must contain 10-15 digits only.", null));
                }
                break;
            case "driver_licence":
                if ("DRIVER".equalsIgnoreCase(role) && (value == null || value.trim().isEmpty())) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Driver licence is required for drivers.", null));
                }
                if (value != null && !value.matches(LICENCE_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Driver licence format is invalid.", null));
                }
                break;
            case "password":
                if (value.length() < 8) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Password must be at least 8 characters long.", null));
                }
                // Optionally add more password strength checks here
                break;
            case "role":
                if (!value.matches("ADMIN|DRIVER|USER")) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Role must be ADMIN, DRIVER, or USER.", null));
                }
                break;
        }
    }

    private boolean isUniqueField(String fieldName) {
        return fieldName.equals("username") || fieldName.equals("email") ||
               fieldName.equals("phone_number") || fieldName.equals("driver_licence");
    }

    private String getFieldLabel(String fieldName) {
        return switch (fieldName) {
            case "username" -> "Username";
            case "email" -> "Email";
            case "phone_number" -> "Phone number";
            case "driver_licence" -> "Driver licence";
            default -> fieldName;
        };
    }

    private boolean fieldExists(String fieldName, String fieldValue, Object userIdObj) {
        String dbColumn = switch (fieldName) {
            case "phone_number" -> "phone_number";
            case "driver_licence" -> "driver_licence";
            default -> fieldName;
        };

        String sql = (userIdObj != null)
            ? "SELECT COUNT(*) FROM users WHERE " + dbColumn + " = ? AND id <> ?"
            : "SELECT COUNT(*) FROM users WHERE " + dbColumn + " = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fieldValue);
            if (userIdObj != null) ps.setObject(2, userIdObj);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            throw new RuntimeException("Database error while validating " + fieldName, e);
        }
    }
} 