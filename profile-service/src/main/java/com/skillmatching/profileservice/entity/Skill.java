package com.skillmatching.profileservice.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;

// Skill Entity - Embedded in Profile document
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Skill {

    @Id
    private String id;

    @Field("skill_id")
    @JsonProperty("skillId")
    private String skillId;

    @Field("skill_name")
    @JsonProperty("skillName")
    private String skillName;

    @Field("proficiency_level")
    @JsonProperty("proficiencyLevel")
    private Integer proficiencyLevel;

    @Field("years_experience")
    @JsonProperty("yearsExperience")
    private Integer yearsExperience;

    @Field("endorsement_count")
    @JsonProperty("endorsementCount")
    private Integer endorsementCount = 0;

    @Field("created_at")
    @JsonProperty("createdAt")
    private LocalDateTime createdAt;

    public Skill(String skillId, String skillName, Integer proficiencyLevel) {
        this.skillId = skillId;
        this.skillName = skillName;
        this.proficiencyLevel = proficiencyLevel;
        this.endorsementCount = 0;
        this.createdAt = LocalDateTime.now();
    }
}
