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

import java.time.LocalDateTime;
import java.util.UUID;

@RestController
@RequestMapping("/api/profiles")
@CrossOrigin(origins = "*")
public class ProfileController {

    @Autowired
    private ProfileService profileService;

    @PostMapping("/create")
    public ResponseEntity<?> createProfile(@RequestBody Profile profile, Authentication authentication) {
        String userId = authentication.getName();
        profile.setUserId(userId);
        Profile created = profileService.createProfile(profile);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{userId}")
    public ResponseEntity<?> getProfile(@PathVariable("userId") String userId) {
        try {
            Profile profile = profileService.getProfileByUserId(userId);
            return ResponseEntity.ok(profile);
        } catch (RuntimeException e) {
            try {
                Profile profile = profileService.getProfileById(userId);
                return ResponseEntity.ok(profile);
            } catch (RuntimeException ex) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("Profile not found with userId or id: " + userId);
            }
        }
    }

    @PutMapping("/{userId}")
    public ResponseEntity<?> updateProfile(
            @PathVariable String userId,
            @RequestBody Profile profileUpdate,
            Authentication authentication) {
        
        Profile existing = profileService.getProfileByUserId(userId);
        String currentUserId = authentication.getName();
        
        if (!existing.getUserId().equals(currentUserId) &&
            !authentication.getAuthorities().stream()
                .anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("You can only update your own profile or you need admin privileges");
        }

        Profile updated = profileService.updateProfile(existing.getId(), profileUpdate);
        return ResponseEntity.ok(updated);
    }

    @PostMapping("/{userId}/skills")
    public ResponseEntity<?> addSkill(
            @PathVariable String userId,
            @RequestBody Skill skill,
            Authentication authentication) {
        
        try {
            Profile existing = profileService.getProfileByUserId(userId);
            String currentUserId = authentication.getName();
            
            if (!existing.getUserId().equals(currentUserId) &&
                !authentication.getAuthorities().stream()
                    .anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"))) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("You can only add skills to your own profile");
            }

            // Initialiser les champs manquants
            if (skill.getSkillId() == null || skill.getSkillId().isEmpty()) {
                skill.setSkillId(UUID.randomUUID().toString());
            }
            if (skill.getCreatedAt() == null) {
                skill.setCreatedAt(LocalDateTime.now());
            }
            if (skill.getEndorsementCount() == null) {
                skill.setEndorsementCount(0);
            }

            profileService.addSkill(existing.getId(), skill);
            return ResponseEntity.ok("Skill added successfully");
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Error: " + e.getMessage());
        }
    }

    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> getAllProfiles() {
        return ResponseEntity.ok(profileService.getAllProfiles());
    }

    @DeleteMapping("/{profileId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteProfile(@PathVariable String profileId) {
        profileService.deleteProfile(profileId);
        return ResponseEntity.ok("Profile deleted successfully");
    }
}