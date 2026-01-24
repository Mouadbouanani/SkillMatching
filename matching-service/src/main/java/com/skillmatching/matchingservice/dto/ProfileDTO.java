package com.skillmatching.matchingservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for Profile data received from profile-service.
 * Used for inter-service communication.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProfileDTO {
    private String id;
    private String userId;
    private String displayName;
    private String bio;
    private Double rating;
    private Integer ratingCount;
    private String location;
    private String availability;
    private String profilePictureUrl;
    private List<SkillDTO> skills;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
