package com.skillmatching.userservice.dto;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthResponse {

    private String idToken;
    private String refreshToken;
    private String uid;
    private UserDTO user;
}