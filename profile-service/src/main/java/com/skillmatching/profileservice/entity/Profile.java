package com.skillmatching.profileservice.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "profiles")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Profile {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(unique = true, nullable = false)
    private String userId;

    @Column(nullable = false)
    private String displayName;

    private String bio;

    @Column(columnDefinition = "NUMERIC(3,2) DEFAULT 0.0")
    private Double rating;

    @Column(columnDefinition = "INTEGER DEFAULT 0")
    private Integer ratingCount;

    private String location;

    @Column(columnDefinition = "jsonb")
    private String availability;

    private String profilePictureUrl;

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "profile_id")
    private List<Skill> skills;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        rating = 0.0;
        ratingCount = 0;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}

