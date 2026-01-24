package com.skillmatching.jobservice.repository;

import com.skillmatching.jobservice.entity.Job;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface JobRepository extends JpaRepository<Job, String> {
    List<Job> findByRequesterId(String requesterId);

    List<Job> findByStatus(Job.JobStatus status);

    // Search by title or description
    List<Job> findByTitleContainingIgnoreCaseOrDescriptionContainingIgnoreCase(
            String titleKeyword, String descriptionKeyword);

    // Find by location
    List<Job> findByLocationContainingIgnoreCase(String location);
}