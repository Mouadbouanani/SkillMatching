package com.skillmatching.matchingservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO for Skill data from profile-service.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SkillDTO {
    private String skillId;
    private String skillName;
    private Integer proficiencyLevel;
    private Integer yearsExperience;
    private Integer endorsementCount;
    private LocalDateTime createdAt;
}
