package com.skillmatching.jobservice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "job_skills")
@Data
@NoArgsConstructor
@AllArgsConstructor
class JobSkill {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String skillId;

    private String skillName;

    @Column(nullable = false)
    private Integer requiredLevel;

    private LocalDateTime createdAt;
}