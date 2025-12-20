package com.skillmatching.matchingservice.repository;

import com.skillmatching.matchingservice.entity.Match;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MatchRepository extends JpaRepository<Match, String> {
    java.util.List<Match> findByJobId(String jobId);
    java.util.List<Match> findByProviderId(String providerId);
}