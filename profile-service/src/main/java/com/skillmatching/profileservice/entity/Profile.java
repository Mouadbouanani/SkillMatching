package com.skillmatching.profileservice.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Document(collection = "profiles")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Profile {

    @Id
    private String id;

    @Indexed(unique = true)
    @Field("user_id")
    @JsonProperty("userId")
    private String userId;

    @Field("display_name")
    @JsonProperty("displayName")
    private String displayName;

    private String bio;

    private Double rating = 0.0;

    @Field("rating_count")
    @JsonProperty("ratingCount")
    private Integer ratingCount = 0;

    private String location;

    private String availability; // JSON string or can be a Map

    @Field("profile_picture_url")
    @JsonProperty("profilePictureUrl")
    private String profilePictureUrl;

    private List<Skill> skills = new ArrayList<>();

    @CreatedDate
    @Field("created_at")
    @JsonProperty("createdAt")
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Field("updated_at")
    @JsonProperty("updatedAt")
    private LocalDateTime updatedAt;

    // Lifecycle callback methods for MongoDB
    @org.springframework.data.annotation.PersistenceConstructor
    public Profile(String userId, String displayName) {
        this.userId = userId;
        this.displayName = displayName;
        this.rating = 0.0;
        this.ratingCount = 0;
        this.skills = new ArrayList<>();
    }

    // Pre-save callback
    public void prePersist() {
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
        if (this.updatedAt == null) {
            this.updatedAt = LocalDateTime.now();
        }
        if (this.rating == null) {
            this.rating = 0.0;
        }
        if (this.ratingCount == null) {
            this.ratingCount = 0;
        }
        if (this.skills == null) {
            this.skills = new ArrayList<>();
        }
    }

    // Pre-update callback
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}

