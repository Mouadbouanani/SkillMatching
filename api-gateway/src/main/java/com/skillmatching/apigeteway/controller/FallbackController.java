package com.skillmatching.apigeteway.controller;


import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/fallback")
public class FallbackController {

    @GetMapping("/auth")
    public ResponseEntity<?> authFallback() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Auth Service temporarily unavailable");
        response.put("status", "SERVICE_DOWN");
        return ResponseEntity.status(503).body(response);
    }

    @GetMapping("/profile")
    public ResponseEntity<?> profileFallback() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Profile Service temporarily unavailable");
        response.put("status", "SERVICE_DOWN");
        return ResponseEntity.status(503).body(response);
    }

    @GetMapping("/job")
    public ResponseEntity<?> jobFallback() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Job Service temporarily unavailable");
        response.put("status", "SERVICE_DOWN");
        return ResponseEntity.status(503).body(response);
    }

    @GetMapping("/match")
    public ResponseEntity<?> matchFallback() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Matching Service temporarily unavailable");
        response.put("status", "SERVICE_DOWN");
        return ResponseEntity.status(503).body(response);
    }
}