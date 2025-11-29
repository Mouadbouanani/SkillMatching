package com.skillmatching.userservice.dto;


import com.skillmatching.userservice.entity.User.UserRole;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UpdateRoleRequest {

    @NotNull(message = "Le nouveau rôle est requis")
    private UserRole newRole;
}