package com.skillmatching.profileservice.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.skillmatching.profileservice.entity.Profile;
import com.skillmatching.profileservice.entity.Skill;
import com.skillmatching.profileservice.repository.ProfileRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.MongoDBContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.ArrayList;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@Testcontainers
class ProfileControllerTest {

    @Container
    static MongoDBContainer mongoDBContainer = new MongoDBContainer("mongo:latest")
            .withReuse(true);

    @DynamicPropertySource
    static void setProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.data.mongodb.uri", mongoDBContainer::getReplicaSetUrl);
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ProfileRepository profileRepository;

    @BeforeEach
    void setUp() {
        profileRepository.deleteAll();
    }

    @Test
    @WithMockUser(username = "test-user-123")
    void testCreateProfile() throws Exception {
        Profile profile = new Profile();
        profile.setDisplayName("Test User");
        profile.setBio("Test bio");
        profile.setLocation("Paris");
        profile.setSkills(new ArrayList<>());

        mockMvc.perform(post("/create")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(profile)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.displayName").value("Test User"))
                .andExpect(jsonPath("$.userId").value("test-user-123"));
    }

    @Test
    @WithMockUser(username = "test-user-456")
    void testGetProfile() throws Exception {
        // Create a profile first
        Profile profile = new Profile();
        profile.setUserId("test-user-456");
        profile.setDisplayName("Test User");
        profile.setSkills(new ArrayList<>());
        profileRepository.save(profile);

        mockMvc.perform(get("/test-user-456"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value("test-user-456"))
                .andExpect(jsonPath("$.displayName").value("Test User"));
    }

    @Test
    @WithMockUser(username = "test-user-789")
    void testUpdateProfile() throws Exception {
        // Create a profile first
        Profile profile = new Profile();
        profile.setUserId("test-user-789");
        profile.setDisplayName("Original Name");
        profile.setSkills(new ArrayList<>());
        Profile saved = profileRepository.save(profile);

        Profile update = new Profile();
        update.setDisplayName("Updated Name");
        update.setBio("Updated bio");

        mockMvc.perform(put("/" + saved.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(update)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.displayName").value("Updated Name"))
                .andExpect(jsonPath("$.bio").value("Updated bio"));
    }

    @Test
    @WithMockUser(username = "test-user-skills")
    void testAddSkill() throws Exception {
        // Create a profile first
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

        mockMvc.perform(post("/" + saved.getId() + "/skills")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(skill)))
                .andExpect(status().isOk());
    }
}

