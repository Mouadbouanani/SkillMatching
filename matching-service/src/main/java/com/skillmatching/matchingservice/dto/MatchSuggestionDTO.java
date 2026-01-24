package com.skillmatching.matchingservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for match suggestions returned to clients.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MatchSuggestionDTO {
    private String matchId;
    private String jobId;
    private String jobTitle;
    private String providerId;
    private String providerName;
    private String providerProfilePictureUrl;
    private Double matchScore;
    private String matchStatus;

    // Breakdown of scoring components
    private Double skillMatchScore;
    private Double experienceScore;
    private Double ratingScore;
    private Double locationScore;
}
