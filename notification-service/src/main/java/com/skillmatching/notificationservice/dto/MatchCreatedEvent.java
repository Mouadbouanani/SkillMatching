package com.skillmatching.notificationservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Event received from matching-service when a new match is created.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MatchCreatedEvent {
    private String matchId;
    private String jobId;
    private String jobTitle;
    private String providerId;
    private Double matchScore;
}
