package com.skillmatching.profileservice.service;

import com.skillmatching.profileservice.entity.Profile;
import com.skillmatching.profileservice.entity.Skill;
import com.skillmatching.profileservice.repository.ProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@Service
public class ProfileService {

    @Autowired
    private ProfileRepository profileRepository;

    @Autowired
    private RedisTemplate<String, Profile> redisTemplate;

    public Profile createProfile(Profile profile) {
        Profile saved = profileRepository.save(profile);
        redisTemplate.opsForValue().set("profile:" + saved.getId(), saved);
        return saved;
    }

    @Cacheable(value = "profiles", key = "#userId")
    public Profile getProfileByUserId(String userId) {
        return profileRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));
    }

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

        Profile updated = profileRepository.save(profile);
        redisTemplate.opsForValue().set("profile:" + updated.getId(), updated);
        return updated;
    }

    public void addSkill(String profileId, Skill skill) {
        Profile profile = profileRepository.findById(profileId)
                .orElseThrow(() -> new RuntimeException("Profile not found"));
        profile.getSkills().add(skill);
        profileRepository.save(profile);
    }
}