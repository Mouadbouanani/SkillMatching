package com.skillmatching.matchingservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for JobSkill data received from job-service.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class JobSkillDTO {
    private String id;
    private String skillId;
    private String skillName;
    private Integer requiredLevel;
}
