package com.skillmatching.matchingservice.controller;

import com.skillmatching.matchingservice.dto.MatchSuggestionDTO;
import com.skillmatching.matchingservice.entity.Match;
import com.skillmatching.matchingservice.service.MatchingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST Controller for matching operations.
 * Base path: /api/matches (configured in application.yml context-path)
 */
@RestController
@RequestMapping
@CrossOrigin(origins = "*")
public class MatchingController {

    @Autowired
    private MatchingService matchingService;

    /**
     * Manually trigger matching process for a job.
     * POST /api/matches/trigger/{jobId}
     */
    @PostMapping("/trigger/{jobId}")
    public ResponseEntity<?> triggerMatching(@PathVariable String jobId) {
        matchingService.createMatches(jobId);
        return ResponseEntity.ok(Map.of(
                "message", "Matching triggered successfully",
                "jobId", jobId));
    }

    /**
     * Get match suggestions for a job with detailed provider info.
     * GET /api/matches/suggestions/{jobId}
     */
    @GetMapping("/suggestions/{jobId}")
    public ResponseEntity<List<MatchSuggestionDTO>> getMatchSuggestions(@PathVariable String jobId) {
        List<MatchSuggestionDTO> suggestions = matchingService.getMatchSuggestions(jobId);
        return ResponseEntity.ok(suggestions);
    }

    /**
     * Get all matches for a specific job.
     * GET /api/matches/job/{jobId}
     */
    @GetMapping("/job/{jobId}")
    public ResponseEntity<List<Match>> getMatchesByJob(@PathVariable String jobId) {
        List<Match> matches = matchingService.getMatchesByJobId(jobId);
        return ResponseEntity.ok(matches);
    }

    /**
     * Get all matches for a specific provider.
     * GET /api/matches/provider/{providerId}
     */
    @GetMapping("/provider/{providerId}")
    public ResponseEntity<List<Match>> getMatchesByProvider(@PathVariable String providerId) {
        List<Match> matches = matchingService.getMatchesByProviderId(providerId);
        return ResponseEntity.ok(matches);
    }

    /**
     * Accept a match (provider or client action).
     * POST /api/matches/{matchId}/accept
     */
    @PostMapping("/{matchId}/accept")
    public ResponseEntity<Match> acceptMatch(@PathVariable String matchId) {
        Match accepted = matchingService.acceptMatch(matchId);
        return ResponseEntity.ok(accepted);
    }

    /**
     * Reject a match.
     * POST /api/matches/{matchId}/reject
     */
    @PostMapping("/{matchId}/reject")
    public ResponseEntity<Match> rejectMatch(@PathVariable String matchId) {
        Match rejected = matchingService.rejectMatch(matchId);
        return ResponseEntity.ok(rejected);
    }

    /**
     * Calculate compatibility score between a job and a profile.
     * POST /api/matches/compatibility
     */
    @PostMapping("/compatibility")
    public ResponseEntity<?> calculateCompatibility(
            @RequestParam String jobId,
            @RequestParam String profileId) {
        Double score = matchingService.calculateMatchScore(jobId, profileId);
        return ResponseEntity.ok(Map.of(
                "jobId", jobId,
                "profileId", profileId,
                "compatibilityScore", score));
    }

    /**
     * Health check endpoint.
     * GET /api/matches/health
     */
    @GetMapping("/health")
    public ResponseEntity<?> health() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "matching-service"));
    }
}