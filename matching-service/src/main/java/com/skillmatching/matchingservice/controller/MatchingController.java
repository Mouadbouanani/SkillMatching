package com.skillmatching.matchingservice.controller;


import com.skillmatching.matchingservice.entity.Match;
import com.skillmatching.matchingservice.service.MatchingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping
@CrossOrigin(origins = "*")
public class MatchingController {

    @Autowired
    private MatchingService matchingService;

    @PostMapping("/trigger/{jobId}")
    public ResponseEntity<?> triggerMatching(@PathVariable String jobId) {
        matchingService.createMatches(jobId);
        return ResponseEntity.ok("Matching triggered");
    }

    @PostMapping("/{matchId}/accept")
    public ResponseEntity<?> acceptMatch(@PathVariable String matchId) {
        Match accepted = matchingService.acceptMatch(matchId);
        return ResponseEntity.ok(accepted);
    }
}