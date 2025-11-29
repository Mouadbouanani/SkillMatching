package com.skillmatching.userservice.dto;


public class ErrorResponse {
    private String message;

    // Constructor
    public ErrorResponse(String message) {
        this.message = message;
    }

    // Getter (optional but good practice for JSON serialization)
    public String getMessage() {
        return message;
    }

    // Setter (optional)
    public void setMessage(String message) {
        this.message = message;
    }
}