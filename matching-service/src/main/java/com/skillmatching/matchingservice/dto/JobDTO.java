package com.skillmatching.matchingservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for Job data received from job-service.
 * Used for inter-service communication.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class JobDTO {
    private String id;
    private String requesterId;
    private String title;
    private String description;
    private BigDecimal budget;
    private String currency;
    private String status;
    private String location;
    private LocalDateTime deadline;
    private List<JobSkillDTO> requiredSkills;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
