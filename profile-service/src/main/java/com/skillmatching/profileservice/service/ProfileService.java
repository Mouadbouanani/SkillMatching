package com.skillmatching.profileservice.service;

import com.skillmatching.profileservice.entity.Profile;
import com.skillmatching.profileservice.entity.Skill;
import com.skillmatching.profileservice.repository.ProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProfileService {

    @Autowired
    private ProfileRepository profileRepository;

    @Autowired
    private RedisTemplate<String, Profile> redisTemplate;

    public Profile createProfile(Profile profile) {
        // Initialize skills list if null
        if (profile.getSkills() == null) {
            profile.setSkills(new java.util.ArrayList<>());
        }
        // Check if profile already exists for this user
        if (profileRepository.existsByUserId(profile.getUserId())) {
            throw new RuntimeException("Profile already exists for this user");
        }
        profile.prePersist();
        Profile saved = profileRepository.save(profile);
        // Try to cache in Redis, but don't fail if Redis is not available
        try {
            redisTemplate.opsForValue().set("profile:" + saved.getId(), saved);
        } catch (Exception e) {
            // Redis not available, continue without cache
            System.out.println("Warning: Redis not available, skipping cache: " + e.getMessage());
        }
        return saved;
    }

    @Cacheable(value = "profiles", key = "#userId")
    public Profile getProfileByUserId(String userId) {
        return profileRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));
    }

    public Profile getProfileById(String profileId) {
        return profileRepository.findById(profileId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));
    }

    public List<Profile> getAllProfiles() {
        return profileRepository.findAll();
    }

    /**
     * Search profiles by skill names.
     * Used by matching-service for finding candidate providers.
     *
     * @param skillNames list of skill names to search for
     * @return list of profiles that have matching skills
     */
    public List<Profile> searchBySkillNames(List<String> skillNames) {
        if (skillNames == null || skillNames.isEmpty()) {
            return profileRepository.findAll();
        }

        // Convert to lowercase for case-insensitive matching
        List<String> normalizedSkills = skillNames.stream()
                .map(String::toLowerCase)
                .collect(java.util.stream.Collectors.toList());

        return profileRepository.findBySkillNames(normalizedSkills);
    }

    @CacheEvict(value = "profiles", key = "#profileId")
    public Profile updateProfile(String profileId, Profile profileUpdate) {
        Profile profile = profileRepository.findById(profileId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));

        if (profileUpdate.getDisplayName() != null) {
            profile.setDisplayName(profileUpdate.getDisplayName());
        }
        if (profileUpdate.getBio() != null) {
            profile.setBio(profileUpdate.getBio());
        }
        if (profileUpdate.getAvailability() != null) {
            profile.setAvailability(profileUpdate.getAvailability());
        }
        if (profileUpdate.getLocation() != null) {
            profile.setLocation(profileUpdate.getLocation());
        }
        if (profileUpdate.getProfilePictureUrl() != null) {
            profile.setProfilePictureUrl(profileUpdate.getProfilePictureUrl());
        }

        profile.preUpdate();
        Profile updated = profileRepository.save(profile);
        // Try to cache in Redis, but don't fail if Redis is not available
        try {
            redisTemplate.opsForValue().set("profile:" + updated.getId(), updated);
        } catch (Exception e) {
            // Redis not available, continue without cache
            System.out.println("Warning: Redis not available, skipping cache: " + e.getMessage());
        }
        return updated;
    }

    @CacheEvict(value = "profiles", allEntries = true)
    public void addSkill(String profileId, Skill skill) {
        Profile profile = profileRepository.findById(profileId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));

        if (profile.getSkills() == null) {
            profile.setSkills(new java.util.ArrayList<>());
        }

        // Initialize skill if needed
        if (skill.getCreatedAt() == null) {
            skill.setCreatedAt(java.time.LocalDateTime.now());
        }

        profile.getSkills().add(skill);
        profile.preUpdate();
        Profile updated = profileRepository.save(profile);
        // Try to cache in Redis, but don't fail if Redis is not available
        try {
            redisTemplate.opsForValue().set("profile:" + updated.getId(), updated);
        } catch (Exception e) {
            // Redis not available, continue without cache
            System.out.println("Warning: Redis not available, skipping cache: " + e.getMessage());
        }
    }

    public void deleteProfile(String profileId) {
        Profile profile = profileRepository.findById(profileId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));

        profileRepository.deleteById(profileId);

        // Remove from cache if present
        try {
            redisTemplate.delete("profile:" + profileId);
        } catch (Exception e) {
            // Redis not available, continue without cache
            System.out.println("Warning: Redis not available, skipping cache removal: " + e.getMessage());
        }
    }

    /**
     * Submit a new rating for a user.
     * Calculates the new average rating.
     *
     * @param userId    the user ID being rated
     * @param newRating the rating value (1-5)
     */
    @CacheEvict(value = "profiles", key = "#userId")
    public void submitRating(String userId, Double newRating) {
        if (newRating < 1.0 || newRating > 5.0) {
            throw new IllegalArgumentException("Rating must be between 1.0 and 5.0");
        }

        Profile profile = profileRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));

        Double currentRating = profile.getRating() != null ? profile.getRating() : 0.0;
        Integer currentCount = profile.getRatingCount() != null ? profile.getRatingCount() : 0;

        // Calculate new average
        Double totalScore = (currentRating * currentCount) + newRating;
        Integer newCount = currentCount + 1;
        Double newAverage = totalScore / newCount;

        profile.setRating(newAverage);
        profile.setRatingCount(newCount);
        profile.preUpdate();

        profileRepository.save(profile);

        // Update cache
        try {
            redisTemplate.opsForValue().set("profile:" + profile.getId(), profile);
        } catch (Exception e) {
            System.out.println("Warning: Redis not available, skipping cache: " + e.getMessage());
        }
    }
}