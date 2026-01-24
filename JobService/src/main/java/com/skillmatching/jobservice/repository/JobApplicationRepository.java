package com.skillmatching.jobservice.repository;

import com.skillmatching.jobservice.entity.JobApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface JobApplicationRepository extends JpaRepository<JobApplication, String> {
    List<JobApplication> findByJobId(String jobId);

    List<JobApplication> findByProviderId(String providerId);

    Optional<JobApplication> findByJobIdAndProviderId(String jobId, String providerId);

    long countByJobId(String jobId);
}
