package com.skillmatching.userservice.dto;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class UserDTO {

    private String id;
    private String email;
    private String firebaseUid;
    private String role;
    private Boolean emailVerified;
    private Boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}