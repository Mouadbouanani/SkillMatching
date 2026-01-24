package com.skillmatching.matchingservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Event published when a new match is created.
 * Consumed by notification-service to notify the provider.
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
