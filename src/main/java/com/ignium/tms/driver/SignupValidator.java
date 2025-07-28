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

@FacesValidator("signupValidator")
public class SignupValidator implements Validator<String> {

    private static final String USERNAME_PATTERN = "^[a-zA-Z0-9_]{4,}$";
    private static final String EMAIL_PATTERN = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
    private static final String PASSWORD_PATTERN = ".{8,}";

    private DataSource dataSource;

    public SignupValidator() {
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

        if (fieldName == null) return;

        switch (fieldName) {
            case "username":
                if (!value.matches(USERNAME_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                            "Username must be at least 4 characters and contain only letters, numbers, and underscores.", null));
                }
                if (fieldExists("username", value)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                            "Username already exists. Please choose a different one.", null));
                }
                break;
            case "email":
                if (!value.matches(EMAIL_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                            "Please enter a valid email address.", null));
                }
                if (fieldExists("email", value)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                            "Email already exists. Please use a different one.", null));
                }
                break;
            case "password":
                if (!value.matches(PASSWORD_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                            "Password must be at least 8 characters long.", null));
                }
                break;
            case "role":
                if (!value.matches("ADMIN|DRIVER|USER")) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                            "Role must be ADMIN, DRIVER, or USER.", null));
                }
                break;
        }
    }

    private boolean fieldExists(String fieldName, String value) {
        String sql = "SELECT COUNT(*) FROM users WHERE " + fieldName + " = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, value);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            throw new RuntimeException("Database error during uniqueness check for " + fieldName, e);
        }
    }
} 
