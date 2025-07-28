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

@FacesValidator("busValidator")
public class BusValidator implements Validator<Object> {

    private static final String PLATE_PATTERN = "^[A-Z0-9-]{5,20}$";
    private static final String MODEL_PATTERN = "^.{2,100}$";
    private static final String OWNER_ID_PATTERN = "^[0-9]{5,20}$";
    private static final String SACCO_PATTERN = "^.{0,100}$";

    private DataSource dataSource;

    public BusValidator() {
        try {
            InitialContext ctx = new InitialContext();
            dataSource = (DataSource) ctx.lookup("java:global/nganya1");
        } catch (Exception e) {
            throw new RuntimeException("Failed to initialize data source", e);
        }
    }

    @Override
    public void validate(FacesContext context, UIComponent component, Object value) throws ValidatorException {
        if (value == null || value.toString().trim().isEmpty()) {
            return; // Let required validator handle empty values
        }

        String fieldName = (String) component.getAttributes().get("fieldName");
        Object vehicleIdObj = component.getAttributes().get("vehicleId");
        String strValue = value.toString();

        if (fieldName == null) return;

        // Uniqueness check for plate_number
        if (fieldName.equals("plate_number") && fieldExists(fieldName, strValue, vehicleIdObj)) {
            throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                "Plate Number already exists. Please choose a different one.", null));
        }

        // Field-specific validation
        switch (fieldName) {
            case "plate_number":
                if (!strValue.matches(PLATE_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Plate Number must be 5-20 characters, uppercase letters, numbers, or dashes.", null));
                }
                break;
            case "vehicle_model":
                if (!strValue.matches(MODEL_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Model must be 2-100 characters.", null));
                }
                break;
            case "owner_national_id":
                if (!strValue.matches(OWNER_ID_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Owner ID must be 5-20 digits.", null));
                }
                break;
            case "capacity":
                try {
                    int cap = Integer.parseInt(strValue);
                    if (cap <= 0) {
                        throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                            "Capacity must be a positive number.", null));
                    }
                } catch (NumberFormatException e) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Capacity must be a valid number.", null));
                }
                break;
            case "sacco":
                if (!strValue.matches(SACCO_PATTERN)) {
                    throw new ValidatorException(new FacesMessage(FacesMessage.SEVERITY_ERROR,
                        "Sacco must be at most 100 characters.", null));
                }
                break;
        }
    }

    private boolean fieldExists(String fieldName, String fieldValue, Object vehicleIdObj) {
        String dbColumn = fieldName;
        String sql = (vehicleIdObj != null)
            ? "SELECT COUNT(*) FROM vehicle WHERE " + dbColumn + " = ? AND id <> ?"
            : "SELECT COUNT(*) FROM vehicle WHERE " + dbColumn + " = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fieldValue);
            if (vehicleIdObj != null) ps.setObject(2, vehicleIdObj);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            throw new RuntimeException("Database error while validating " + fieldName, e);
        }
    }
} 