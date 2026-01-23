package com.skillmatching.userservice.dto;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UserRegistrationDTO {

    @Email(message = "Email invalide")
    private String email;

    @NotBlank(message = "Password requis")
    @Size(min = 6, message = "Password minimum 6 caracteres")
    private String password;

    @NotBlank(message = "Display name requis")
    private String displayName;

    private String phoneNumber;

    private String role; // CLIENT ou PROVIDER ou Admin
}