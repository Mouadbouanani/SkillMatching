package com.skillmatching.userservice.dto;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AuthRequest {

    @Email(message = "Email format invalide")
    private String email;

    @NotBlank(message = "Password requis")
    private String password;
}