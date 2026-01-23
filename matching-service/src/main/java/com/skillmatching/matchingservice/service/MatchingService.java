package com.skillmatching.matchingservice.service;

import com.skillmatching.matchingservice.entity.Match;
import com.skillmatching.matchingservice.repository.MatchRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

@Service
public class MatchingService {

    @Autowired
    private MatchRepository matchRepository;

    @Autowired
    private WebClient webClient;

    public void createMatches(String jobId) {
        // Get job details
        // Query profiles with matching skills
        // Calculate match scores using TF-IDF algorithm
        // Create match records
    }

    public Double calculateMatchScore(String jobId, String profileId) {
        // TF-IDF algorithm implementation
        // Geo-proximity calculation
        // Rating/reviews weighting
        return 0.0;
    }

    public Match acceptMatch(String matchId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new RuntimeException("Match not found"));
        match.setStatus(Match.MatchStatus.ACCEPTED);
        match.setAcceptedAt(java.time.LocalDateTime.now());
        return matchRepository.save(match);
    }
}
