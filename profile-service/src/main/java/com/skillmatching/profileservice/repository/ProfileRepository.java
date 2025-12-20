package com.skillmatching.profileservice.repository;


import com.skillmatching.profileservice.entity.Profile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.Optional;
import java.util.List;

public interface ProfileRepository extends JpaRepository<Profile, String> {
    Optional<Profile> findByUserId(String userId);

    @Query("SELECT p FROM Profile p WHERE ST_DWithin(p.location, :point, :radius) = true")
    List<Profile> findNearby(String point, Integer radius);
}