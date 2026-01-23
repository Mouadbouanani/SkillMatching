package com.skillmatching.profileservice.integration;

import com.skillmatching.profileservice.entity.Profile;
import com.skillmatching.profileservice.entity.Skill;
import com.skillmatching.profileservice.repository.ProfileRepository;
import com.skillmatching.profileservice.service.ProfileService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.MongoDBContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@Testcontainers
class ProfileServiceIntegrationTest {

    @Container
    static MongoDBContainer mongoDBContainer = new MongoDBContainer("mongo:latest")
            .withReuse(true);

    @DynamicPropertySource
    static void setProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.data.mongodb.uri", mongoDBContainer::getReplicaSetUrl);
    }

    @Autowired
    private ProfileRepository profileRepository;

    @Autowired
    private ProfileService profileService;

    @BeforeEach
    void setUp() {
        profileRepository.deleteAll();
    }

    @Test
    void testCreateProfile() {
        // Given
        Profile profile = new Profile();
        profile.setUserId("test-user-123");
        profile.setDisplayName("Test User");
        profile.setBio("Test bio");
        profile.setLocation("Paris");
        profile.setSkills(new ArrayList<>());

        // When
        Profile created = profileService.createProfile(profile);

        // Then
        assertNotNull(created.getId());
        assertEquals("test-user-123", created.getUserId());
        assertEquals("Test User", created.getDisplayName());
        assertEquals(0.0, created.getRating());
        assertEquals(0, created.getRatingCount());
        assertNotNull(created.getCreatedAt());
    }

    @Test
    void testGetProfileByUserId() {
        // Given
        Profile profile = new Profile();
        profile.setUserId("test-user-456");
        profile.setDisplayName("Test User 2");
        profile.setSkills(new ArrayList<>());
        profileRepository.save(profile);

        // When
        Profile found = profileService.getProfileByUserId("test-user-456");

        // Then
        assertNotNull(found);
        assertEquals("test-user-456", found.getUserId());
        assertEquals("Test User 2", found.getDisplayName());
    }

    @Test
    void testUpdateProfile() {
        // Given
        Profile profile = new Profile();
        profile.setUserId("test-user-789");
        profile.setDisplayName("Original Name");
        profile.setBio("Original bio");
        profile.setSkills(new ArrayList<>());
        Profile saved = profileRepository.save(profile);

        Profile update = new Profile();
        update.setDisplayName("Updated Name");
        update.setBio("Updated bio");

        // When
        Profile updated = profileService.updateProfile(saved.getId(), update);

        // Then
        assertEquals("Updated Name", updated.getDisplayName());
        assertEquals("Updated bio", updated.getBio());
        assertNotNull(updated.getUpdatedAt());
    }

    @Test
    void testAddSkill() {
        // Given
        Profile profile = new Profile();
        profile.setUserId("test-user-skills");
        profile.setDisplayName("Skills User");
        profile.setSkills(new ArrayList<>());
        Profile saved = profileRepository.save(profile);

        Skill skill = new Skill();
        skill.setSkillId("java-001");
        skill.setSkillName("Java");
        skill.setProficiencyLevel(8);
        skill.setYearsExperience(5);

        // When
        profileService.addSkill(saved.getId(), skill);

        // Then
        Optional<Profile> updated = profileRepository.findById(saved.getId());
        assertTrue(updated.isPresent());
        assertEquals(1, updated.get().getSkills().size());
        assertEquals("Java", updated.get().getSkills().get(0).getSkillName());
    }

    @Test
    void testProfileNotFound() {
        // When/Then
        assertThrows(RuntimeException.class, () -> {
            profileService.getProfileByUserId("non-existent-user");
        });
    }

    @Test
    void testDuplicateUserId() {
        // Given
        Profile profile1 = new Profile();
        profile1.setUserId("duplicate-user");
        profile1.setDisplayName("First");
        profile1.setSkills(new ArrayList<>());
        profileRepository.save(profile1);

        Profile profile2 = new Profile();
        profile2.setUserId("duplicate-user");
        profile2.setDisplayName("Second");
        profile2.setSkills(new ArrayList<>());

        // When/Then
        assertThrows(RuntimeException.class, () -> {
            profileService.createProfile(profile2);
        });
    }
}

