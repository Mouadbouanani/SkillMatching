package com.skillmatching.profileservice.controller;

import com.skillmatching.profileservice.entity.Profile;
import com.skillmatching.profileservice.entity.Skill;
import com.skillmatching.profileservice.service.ProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping
@CrossOrigin(origins = "*")
public class ProfileController {

    @Autowired
    private ProfileService profileService;

    @PostMapping("/create")
    public ResponseEntity<?> createProfile(@RequestBody Profile profile) {
        Profile created = profileService.createProfile(profile);
        return ResponseEntity.ok(created);
    }

    @GetMapping("/{userId}")
    public ResponseEntity<?> getProfile(@PathVariable String userId) {
        Profile profile = profileService.getProfileByUserId(userId);
        return ResponseEntity.ok(profile);
    }

    @PutMapping("/{profileId}")
    public ResponseEntity<?> updateProfile(
            @PathVariable String profileId,
            @RequestBody Profile profileUpdate) {
        Profile updated = profileService.updateProfile(profileId, profileUpdate);
        return ResponseEntity.ok(updated);
    }

    @PostMapping("/{profileId}/skills")
    public ResponseEntity<?> addSkill(
            @PathVariable String profileId,
            @RequestBody Skill skill) {
        profileService.addSkill(profileId, skill);
        return ResponseEntity.ok("Skill added");
    }
}