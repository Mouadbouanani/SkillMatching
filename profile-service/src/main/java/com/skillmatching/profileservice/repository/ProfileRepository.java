package com.skillmatching.profileservice.repository;

import com.skillmatching.profileservice.entity.Profile;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface ProfileRepository extends MongoRepository<Profile, String> {

    Optional<Profile> findByUserId(String userId);

    boolean existsByUserId(String userId);

    // Find profiles by skill
    @Query("{ 'skills.skillId': ?0 }")
    List<Profile> findBySkillId(String skillId);

    // Find profiles by location (simple text search, can be enhanced with
    // geospatial queries)
    @Query("{ 'location': { $regex: ?0, $options: 'i' } }")
    List<Profile> findByLocationContaining(String location);

    // Find profiles with minimum rating
    @Query("{ 'rating': { $gte: ?0 } }")
    List<Profile> findByRatingGreaterThanEqual(Double minRating);

    // Find profiles by multiple skills
    @Query("{ 'skills.skillId': { $in: ?0 } }")
    List<Profile> findBySkillsIn(List<String> skillIds);

    // Find profiles by skill names (case-insensitive)
    @Query("{ 'skills.skill_name': { $in: ?0 } }")
    List<Profile> findBySkillNames(List<String> skillNames);

    // Find profiles by skill names using regex for partial matching
    @Query("{ 'skills.skill_name': { $regex: ?0, $options: 'i' } }")
    List<Profile> findBySkillNameContaining(String skillNamePattern);
}