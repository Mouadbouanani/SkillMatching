package com.skillmatching.matchingservice.service;

import com.skillmatching.matchingservice.client.JobServiceClient;
import com.skillmatching.matchingservice.client.ProfileServiceClient;
import com.skillmatching.matchingservice.dto.*;
import com.skillmatching.matchingservice.entity.Match;
import com.skillmatching.matchingservice.repository.MatchRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Core matching service implementing the skill-based matching algorithm.
 * 
 * Matching Algorithm Overview:
 * ---------------------------
 * The algorithm calculates a composite score (0-100) based on:
 * 1. Skill Match Score (40% weight): How well provider skills match job
 * requirements
 * 2. Experience Score (25% weight): Provider's proficiency and years of
 * experience
 * 3. Rating Score (20% weight): Provider's overall platform rating
 * 4. Location Score (15% weight): Geographic proximity (if location data
 * available)
 * 
 * Providers scoring above the threshold (default: 50) are considered potential
 * matches.
 */
@Service
public class MatchingService {

    private static final Logger logger = LoggerFactory.getLogger(MatchingService.class);

    // Scoring weights (must sum to 1.0)
    private static final double SKILL_MATCH_WEIGHT = 0.40;
    private static final double EXPERIENCE_WEIGHT = 0.25;
    private static final double RATING_WEIGHT = 0.20;
    private static final double LOCATION_WEIGHT = 0.15;

    // Minimum score threshold for creating a match (0-100)
    private static final double MATCH_THRESHOLD = 50.0;

    // Maximum number of matches to create per job
    private static final int MAX_MATCHES_PER_JOB = 10;

    @Autowired
    private MatchRepository matchRepository;

    @Autowired
    private JobServiceClient jobServiceClient;

    @Autowired
    private ProfileServiceClient profileServiceClient;

    @Autowired
    private org.springframework.kafka.core.KafkaTemplate<String, MatchCreatedEvent> matchEventKafkaTemplate;

    /**
     * Creates matches for a given job by finding suitable providers.
     * This method is called automatically when a new job is created (via Kafka
     * listener)
     * or manually via the REST API.
     *
     * @param jobId the ID of the job to match
     */
    @Transactional
    public void createMatches(String jobId) {
        logger.info("Starting matching process for job: {}", jobId);

        // 1. Fetch job details from job-service
        JobDTO job = jobServiceClient.getJobById(jobId);
        if (job == null) {
            logger.error("Job not found: {}", jobId);
            throw new RuntimeException("Job not found: " + jobId);
        }

        // 2. Extract required skill names for searching
        List<String> requiredSkillNames = job.getRequiredSkills() != null
                ? job.getRequiredSkills().stream()
                        .map(JobSkillDTO::getSkillName)
                        .filter(Objects::nonNull)
                        .collect(Collectors.toList())
                : Collections.emptyList();

        if (requiredSkillNames.isEmpty()) {
            logger.warn("Job {} has no required skills, skipping matching", jobId);
            return;
        }

        // 3. Fetch candidate profiles (providers with relevant skills)
        List<ProfileDTO> candidates = profileServiceClient.searchProfilesBySkills(requiredSkillNames);

        // Fallback: if skill search returns empty, get all profiles
        if (candidates.isEmpty()) {
            logger.info("No profiles found via skill search, fetching all profiles for job: {}", jobId);
            candidates = profileServiceClient.getAllProfiles();
        }

        if (candidates.isEmpty()) {
            logger.warn("No candidate profiles found for job: {}", jobId);
            return;
        }

        logger.info("Found {} candidate profiles for job: {}", candidates.size(), jobId);

        // 4. Calculate match scores for each candidate
        List<ScoredProfile> scoredProfiles = candidates.stream()
                .filter(profile -> !profile.getUserId().equals(job.getRequesterId())) // Exclude job owner
                .map(profile -> calculateScoreWithBreakdown(job, profile))
                .filter(scored -> scored.totalScore >= MATCH_THRESHOLD)
                .sorted(Comparator.comparingDouble(ScoredProfile::getTotalScore).reversed())
                .limit(MAX_MATCHES_PER_JOB)
                .collect(Collectors.toList());

        logger.info("Found {} profiles above threshold for job: {}", scoredProfiles.size(), jobId);

        // 5. Create Match entities and persist
        for (ScoredProfile scored : scoredProfiles) {
            // Check if match already exists
            Optional<Match> existingMatch = matchRepository.findByJobIdAndProviderId(jobId, scored.profile.getUserId());
            if (existingMatch.isPresent()) {
                logger.debug("Match already exists for job {} and provider {}", jobId, scored.profile.getUserId());
                continue;
            }

            Match match = new Match();
            match.setJobId(jobId);
            match.setProviderId(scored.profile.getUserId());
            match.setMatchScore(scored.totalScore);
            match.setStatus(Match.MatchStatus.PENDING);

            Match savedMatch = matchRepository.save(match);
            logger.debug("Created match: jobId={}, providerId={}, score={}",
                    jobId, scored.profile.getUserId(), scored.totalScore);

            // Publish match.created event for notification-service
            publishMatchCreatedEvent(savedMatch, job.getTitle());
        }

        logger.info("Matching process completed for job: {}. Created {} matches.", jobId, scoredProfiles.size());
    }

    /**
     * Calculates the compatibility score between a specific job and profile.
     * Used for on-demand compatibility checking.
     *
     * @param jobId     the job ID
     * @param profileId the profile ID (MongoDB profile ID, not userId)
     * @return the match score (0-100)
     */
    public Double calculateMatchScore(String jobId, String profileId) {
        JobDTO job = jobServiceClient.getJobById(jobId);
        if (job == null) {
            throw new RuntimeException("Job not found: " + jobId);
        }

        List<ProfileDTO> allProfiles = profileServiceClient.getAllProfiles();
        ProfileDTO profile = allProfiles.stream()
                .filter(p -> p.getId().equals(profileId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Profile not found: " + profileId));

        ScoredProfile scored = calculateScoreWithBreakdown(job, profile);
        return scored.totalScore;
    }

    /**
     * Accepts a match, changing its status from PENDING to ACCEPTED.
     *
     * @param matchId the match ID
     * @return the updated Match entity
     */
    @Transactional
    public Match acceptMatch(String matchId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new RuntimeException("Match not found: " + matchId));

        if (match.getStatus() != Match.MatchStatus.PENDING) {
            throw new RuntimeException("Match cannot be accepted. Current status: " + match.getStatus());
        }

        match.setStatus(Match.MatchStatus.ACCEPTED);
        match.setAcceptedAt(LocalDateTime.now());

        Match saved = matchRepository.save(match);
        logger.info("Match accepted: {}", matchId);

        // TODO: Publish event to notify provider and update job status

        return saved;
    }

    /**
     * Rejects a match, changing its status from PENDING to REJECTED.
     *
     * @param matchId the match ID
     * @return the updated Match entity
     */
    @Transactional
    public Match rejectMatch(String matchId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new RuntimeException("Match not found: " + matchId));

        if (match.getStatus() != Match.MatchStatus.PENDING) {
            throw new RuntimeException("Match cannot be rejected. Current status: " + match.getStatus());
        }

        match.setStatus(Match.MatchStatus.REJECTED);
        match.setRejectedAt(LocalDateTime.now());

        Match saved = matchRepository.save(match);
        logger.info("Match rejected: {}", matchId);

        return saved;
    }

    /**
     * Gets all matches for a specific job.
     *
     * @param jobId the job ID
     * @return list of matches
     */
    public List<Match> getMatchesByJobId(String jobId) {
        return matchRepository.findByJobId(jobId);
    }

    /**
     * Gets all matches for a specific provider.
     *
     * @param providerId the provider's user ID
     * @return list of matches
     */
    public List<Match> getMatchesByProviderId(String providerId) {
        return matchRepository.findByProviderId(providerId);
    }

    /**
     * Gets match suggestions with detailed information for a job.
     *
     * @param jobId the job ID
     * @return list of match suggestions with provider details
     */
    public List<MatchSuggestionDTO> getMatchSuggestions(String jobId) {
        List<Match> matches = matchRepository.findByJobId(jobId);
        JobDTO job = jobServiceClient.getJobById(jobId);

        if (job == null || matches.isEmpty()) {
            return Collections.emptyList();
        }

        return matches.stream()
                .map(match -> {
                    ProfileDTO profile = profileServiceClient.getProfileByUserId(match.getProviderId());
                    ScoredProfile scored = profile != null
                            ? calculateScoreWithBreakdown(job, profile)
                            : null;

                    MatchSuggestionDTO dto = new MatchSuggestionDTO();
                    dto.setMatchId(match.getId());
                    dto.setJobId(match.getJobId());
                    dto.setJobTitle(job.getTitle());
                    dto.setProviderId(match.getProviderId());
                    dto.setProviderName(profile != null ? profile.getDisplayName() : "Unknown");
                    dto.setProviderProfilePictureUrl(profile != null ? profile.getProfilePictureUrl() : null);
                    dto.setMatchScore(match.getMatchScore());
                    dto.setMatchStatus(match.getStatus().toString());

                    if (scored != null) {
                        dto.setSkillMatchScore(scored.skillMatchScore);
                        dto.setExperienceScore(scored.experienceScore);
                        dto.setRatingScore(scored.ratingScore);
                        dto.setLocationScore(scored.locationScore);
                    }

                    return dto;
                })
                .sorted(Comparator.comparingDouble(MatchSuggestionDTO::getMatchScore).reversed())
                .collect(Collectors.toList());
    }

    // ==================== PRIVATE SCORING METHODS ====================

    /**
     * Calculates the comprehensive score breakdown for a job-profile pair.
     */
    private ScoredProfile calculateScoreWithBreakdown(JobDTO job, ProfileDTO profile) {
        double skillScore = calculateSkillMatchScore(job.getRequiredSkills(), profile.getSkills());
        double experienceScore = calculateExperienceScore(job.getRequiredSkills(), profile.getSkills());
        double ratingScore = calculateRatingScore(profile.getRating(), profile.getRatingCount());
        double locationScore = calculateLocationScore(job.getLocation(), profile.getLocation());

        double totalScore = (skillScore * SKILL_MATCH_WEIGHT)
                + (experienceScore * EXPERIENCE_WEIGHT)
                + (ratingScore * RATING_WEIGHT)
                + (locationScore * LOCATION_WEIGHT);

        // Normalize to 0-100 scale
        totalScore = Math.min(100, Math.max(0, totalScore * 100));

        return new ScoredProfile(profile, totalScore,
                skillScore * 100, experienceScore * 100,
                ratingScore * 100, locationScore * 100);
    }

    /**
     * Calculates skill match score (0-1).
     * Uses a weighted matching where exact skill name matches count more.
     */
    private double calculateSkillMatchScore(List<JobSkillDTO> requiredSkills, List<SkillDTO> providerSkills) {
        if (requiredSkills == null || requiredSkills.isEmpty()) {
            return 0.5; // Neutral score if no skills required
        }
        if (providerSkills == null || providerSkills.isEmpty()) {
            return 0.0;
        }

        Set<String> providerSkillNames = providerSkills.stream()
                .map(s -> s.getSkillName() != null ? s.getSkillName().toLowerCase().trim() : "")
                .collect(Collectors.toSet());

        int matchedSkills = 0;
        int totalRequired = requiredSkills.size();

        for (JobSkillDTO required : requiredSkills) {
            String requiredName = required.getSkillName() != null
                    ? required.getSkillName().toLowerCase().trim()
                    : "";

            // Direct match
            if (providerSkillNames.contains(requiredName)) {
                matchedSkills++;
            } else {
                // Partial match (e.g., "java" matches "java programming")
                for (String providerSkill : providerSkillNames) {
                    if (providerSkill.contains(requiredName) || requiredName.contains(providerSkill)) {
                        matchedSkills++;
                        break;
                    }
                }
            }
        }

        return (double) matchedSkills / totalRequired;
    }

    /**
     * Calculates experience score based on proficiency levels (0-1).
     */
    private double calculateExperienceScore(List<JobSkillDTO> requiredSkills, List<SkillDTO> providerSkills) {
        if (requiredSkills == null || requiredSkills.isEmpty() ||
                providerSkills == null || providerSkills.isEmpty()) {
            return 0.5; // Neutral score
        }

        Map<String, Integer> providerSkillLevels = providerSkills.stream()
                .filter(s -> s.getSkillName() != null && s.getProficiencyLevel() != null)
                .collect(Collectors.toMap(
                        s -> s.getSkillName().toLowerCase().trim(),
                        SkillDTO::getProficiencyLevel,
                        (a, b) -> Math.max(a, b)));

        double totalScore = 0;
        int matchCount = 0;

        for (JobSkillDTO required : requiredSkills) {
            if (required.getSkillName() == null)
                continue;

            String requiredName = required.getSkillName().toLowerCase().trim();
            Integer providerLevel = providerSkillLevels.get(requiredName);

            if (providerLevel != null) {
                int requiredLevel = required.getRequiredLevel() != null ? required.getRequiredLevel() : 1;
                // Score higher if provider level meets or exceeds required
                double levelScore = Math.min(1.0, (double) providerLevel / Math.max(1, requiredLevel));
                totalScore += levelScore;
                matchCount++;
            }
        }

        return matchCount > 0 ? totalScore / matchCount : 0.3;
    }

    /**
     * Calculates rating score (0-1).
     * Higher ratings with more reviews get better scores.
     */
    private double calculateRatingScore(Double rating, Integer ratingCount) {
        if (rating == null || rating <= 0) {
            return 0.5; // Neutral for new providers
        }

        double normalizedRating = rating / 5.0; // Assuming 5-star system

        // Boost score slightly for providers with more reviews (confidence factor)
        double confidenceFactor = 1.0;
        if (ratingCount != null && ratingCount > 0) {
            confidenceFactor = Math.min(1.2, 1.0 + (ratingCount / 50.0)); // Max 20% boost
        }

        return Math.min(1.0, normalizedRating * confidenceFactor);
    }

    /**
     * Calculates location score (0-1).
     * Simple string matching for now. Can be enhanced with geo-distance
     * calculation.
     */
    private double calculateLocationScore(String jobLocation, String profileLocation) {
        if (jobLocation == null || jobLocation.isBlank() ||
                profileLocation == null || profileLocation.isBlank()) {
            return 0.5; // Neutral if location not specified
        }

        String jobLoc = jobLocation.toLowerCase().trim();
        String profLoc = profileLocation.toLowerCase().trim();

        // Exact match
        if (jobLoc.equals(profLoc)) {
            return 1.0;
        }

        // Partial match (same city/region)
        if (jobLoc.contains(profLoc) || profLoc.contains(jobLoc)) {
            return 0.8;
        }

        // TODO: Implement proper geo-distance calculation using coordinates
        return 0.3;
    }

    // ==================== KAFKA EVENT PUBLISHING ====================

    /**
     * Publishes a match.created event to Kafka for notification-service to consume.
     */
    private void publishMatchCreatedEvent(Match match, String jobTitle) {
        try {
            MatchCreatedEvent event = new MatchCreatedEvent(
                    match.getId(),
                    match.getJobId(),
                    jobTitle,
                    match.getProviderId(),
                    match.getMatchScore());
            matchEventKafkaTemplate.send("match.created", match.getId(), event);
            logger.debug("Published match.created event for matchId: {}", match.getId());
        } catch (Exception e) {
            logger.error("Failed to publish match.created event for matchId {}: {}",
                    match.getId(), e.getMessage());
            // Don't fail the transaction if Kafka is unavailable
        }
    }

    // ==================== INNER CLASSES ====================

    /**
     * Internal class to hold a profile with its calculated scores.
     */
    private static class ScoredProfile {
        final ProfileDTO profile;
        final double totalScore;
        final double skillMatchScore;
        final double experienceScore;
        final double ratingScore;
        final double locationScore;

        ScoredProfile(ProfileDTO profile, double totalScore,
                double skillMatchScore, double experienceScore,
                double ratingScore, double locationScore) {
            this.profile = profile;
            this.totalScore = totalScore;
            this.skillMatchScore = skillMatchScore;
            this.experienceScore = experienceScore;
            this.ratingScore = ratingScore;
            this.locationScore = locationScore;
        }

        double getTotalScore() {
            return totalScore;
        }
    }
}
