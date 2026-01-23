package com.skillmatching.profileservice.controller;

import com.skillmatching.profileservice.entity.Profile;
import com.skillmatching.profileservice.entity.Skill;
import com.skillmatching.profileservice.service.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping
@CrossOrigin(origins = "*")
public class ProfileController {

    @Autowired
    private ProfileService profileService;

    @PostMapping("/create")
    public ResponseEntity<?> createProfile(@RequestBody Profile profile, Authentication authentication) {
        // Authentication is required (enforced by SecurityConfig)
        String userId = authentication.getName(); // Firebase UID from token
        profile.setUserId(userId);
        Profile created = profileService.createProfile(profile);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{identifier}")
    public ResponseEntity<?> getProfile(@PathVariable String identifier) {
        // Try to get by userId first, then by profileId
        try {
            Profile profile = profileService.getProfileByUserId(identifier);
            return ResponseEntity.ok(profile);
        } catch (RuntimeException e) {
            // If not found by userId, try by profileId
            try {
                Profile profile = profileService.getProfileById(identifier);
                return ResponseEntity.ok(profile);
            } catch (RuntimeException ex) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("Profile not found with userId or id: " + identifier);
            }
        }
    }

    @PutMapping("/{profileId}")
    public ResponseEntity<?> updateProfile(
            @PathVariable String profileId,
            @RequestBody Profile profileUpdate,
            Authentication authentication) {
        Profile existing = profileService.getProfileById(profileId);
        
        // Verify that the user owns this profile
        String currentUserId = authentication.getName();
        if (!existing.getUserId().equals(currentUserId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("You can only update your own profile");
        }
        
        Profile updated = profileService.updateProfile(profileId, profileUpdate);
        return ResponseEntity.ok(updated);
    }

    @PostMapping("/{profileId}/skills")
    public ResponseEntity<?> addSkill(
            @PathVariable String profileId,
            @RequestBody Skill skill,
            Authentication authentication) {
        Profile existing = profileService.getProfileById(profileId);
        
        // Verify that the user owns this profile
        String currentUserId = authentication.getName();
        if (!existing.getUserId().equals(currentUserId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("You can only add skills to your own profile");
        }
        
        profileService.addSkill(profileId, skill);
        return ResponseEntity.ok("Skill added");
    }
}