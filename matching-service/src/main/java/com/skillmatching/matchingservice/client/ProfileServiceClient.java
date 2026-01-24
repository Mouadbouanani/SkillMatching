package com.skillmatching.matchingservice.client;

import com.skillmatching.matchingservice.dto.ProfileDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.Collections;
import java.util.List;

/**
 * Client for communicating with profile-service via REST.
 */
@Component
public class ProfileServiceClient {

    private static final Logger logger = LoggerFactory.getLogger(ProfileServiceClient.class);

    private final WebClient webClient;

    public ProfileServiceClient(@Qualifier("profileServiceWebClient") WebClient webClient) {
        this.webClient = webClient;
    }

    /**
     * Fetches profile by user ID from profile-service.
     *
     * @param userId the user ID (Firebase UID)
     * @return ProfileDTO with profile details, or null if not found
     */
    public ProfileDTO getProfileByUserId(String userId) {
        try {
            logger.debug("Fetching profile for userId: {}", userId);
            return webClient.get()
                    .uri("/api/profiles/user/{userId}", userId)
                    .retrieve()
                    .bodyToMono(ProfileDTO.class)
                    .block();
        } catch (Exception e) {
            logger.error("Error fetching profile for user {}: {}", userId, e.getMessage());
            return null;
        }
    }

    /**
     * Fetches all profiles from profile-service.
     * NOTE: In production, this should be paginated and filtered.
     *
     * @return List of all profiles
     */
    public List<ProfileDTO> getAllProfiles() {
        try {
            logger.debug("Fetching all profiles");
            return webClient.get()
                    .uri("/api/profiles")
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<List<ProfileDTO>>() {
                    })
                    .block();
        } catch (Exception e) {
            logger.error("Error fetching all profiles: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Searches profiles by skill names.
     * 
     * @param skillNames list of skill names to search for
     * @return List of profiles that have matching skills
     */
    public List<ProfileDTO> searchProfilesBySkills(List<String> skillNames) {
        try {
            logger.debug("Searching profiles by skills: {}", skillNames);
            return webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/api/profiles/skills")
                            .queryParam("skills", String.join(",", skillNames))
                            .build())
                    .retrieve()
                    .bodyToMono(new ParameterizedTypeReference<List<ProfileDTO>>() {
                    })
                    .block();
        } catch (Exception e) {
            logger.error("Error searching profiles by skills: {}", e.getMessage());
            return Collections.emptyList();
        }
    }
}
