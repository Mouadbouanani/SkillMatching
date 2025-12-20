package com.skillmatching.profileservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

// Skill Entity
@Entity
@Table(name = "profile_skills")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Skill {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String skillId;

    private String skillName;

    @Column(nullable = false)
    private Integer proficiencyLevel;

    private Integer yearsExperience;

    @Column(columnDefinition = "INTEGER DEFAULT 0")
    private Integer endorsementCount;

    private LocalDateTime createdAt;
}
