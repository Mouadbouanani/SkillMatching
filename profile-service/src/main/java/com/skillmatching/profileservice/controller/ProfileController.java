package com.skillmatching.profileservice.controller;

import com.skillmatching.profileservice.entity.Profile;
import com.skillmatching.profileservice.entity.Skill;
import com.skillmatching.profileservice.service.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
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

    @GetMapping("/{userId}")
    public ResponseEntity<?> getProfile(@PathVariable("userId") String userId) {        // Try to get by userId first, then by profileId
        try {
            Profile profile = profileService.getProfileByUserId(userId);
            return ResponseEntity.ok(profile);
        } catch (RuntimeException e) {
            // If not found by userId, try by profileId
            try {
                Profile profile = profileService.getProfileById(userId);
                return ResponseEntity.ok(profile);
            } catch (RuntimeException ex) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("Profile not found with userId or id: " + userId);
            }
        }
    }

    @PutMapping("/{profileId}")
    public ResponseEntity<?> updateProfile(
            @PathVariable String profileId,
            @RequestBody Profile profileUpdate,
            Authentication authentication) {
        Profile existing = profileService.getProfileById(profileId);

        // Verify that the user owns this profile or is an admin
        String currentUserId = authentication.getName();
        if (!existing.getUserId().equals(currentUserId) &&
            !authentication.getAuthorities().stream()
                .anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("You can only update your own profile or you need admin privileges");
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

        // Verify that the user owns this profile or is an admin
        String currentUserId = authentication.getName();
        if (!existing.getUserId().equals(currentUserId) &&
            !authentication.getAuthorities().stream()
                .anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("You can only add skills to your own profile or you need admin privileges");
        }

        profileService.addSkill(profileId, skill);
        return ResponseEntity.ok("Skill added");
    }

    // Admin endpoint to get all profiles
    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getAllProfiles() {
        return ResponseEntity.ok(profileService.getAllProfiles());
    }

    // Admin endpoint to delete any profile
    @DeleteMapping("/{profileId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteProfile(@PathVariable String profileId) {
        profileService.deleteProfile(profileId);
        return ResponseEntity.ok("Profile deleted successfully");
    }
}