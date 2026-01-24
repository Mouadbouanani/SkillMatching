package com.skillmatching.matchingservice.repository;

import com.skillmatching.matchingservice.entity.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

/**
 * Repository for Match entities.
 */
public interface MatchRepository extends JpaRepository<Match, String> {

    /**
     * Find all matches for a specific job.
     */
    List<Match> findByJobId(String jobId);

    /**
     * Find all matches for a specific provider.
     */
    List<Match> findByProviderId(String providerId);

    /**
     * Find matches for a job with a specific status.
     */
    List<Match> findByJobIdAndStatus(String jobId, Match.MatchStatus status);

    /**
     * Find matches for a provider with a specific status.
     */
    List<Match> findByProviderIdAndStatus(String providerId, Match.MatchStatus status);

    /**
     * Check if a match already exists between a job and provider.
     */
    Optional<Match> findByJobIdAndProviderId(String jobId, String providerId);

    /**
     * Find top matches for a job, ordered by score.
     */
    @Query("SELECT m FROM Match m WHERE m.jobId = :jobId ORDER BY m.matchScore DESC")
    List<Match> findTopMatchesByJobId(@Param("jobId") String jobId);

    /**
     * Count pending matches for a provider.
     */
    long countByProviderIdAndStatus(String providerId, Match.MatchStatus status);
}