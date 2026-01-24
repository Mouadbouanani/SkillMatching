package com.skillmatching.jobservice.service;

import com.skillmatching.jobservice.entity.Category;
import com.skillmatching.jobservice.entity.Job;
import com.skillmatching.jobservice.entity.JobApplication;
import com.skillmatching.jobservice.repository.CategoryRepository;
import com.skillmatching.jobservice.repository.JobApplicationRepository;
import com.skillmatching.jobservice.repository.JobRepository;
import com.skillmatching.jobservice.event.JobCreatedEvent;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class JobService {

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private JobApplicationRepository applicationRepository;

    @Autowired
    private KafkaTemplate<String, JobCreatedEvent> kafkaTemplate;

    /**
     * Creates a new job and publishes a job.created event to Kafka.
     */
    @Transactional
    public Job createJob(Job job) {
        Job saved = jobRepository.save(job);

        // Publish event to Kafka for matching-service to consume
        JobCreatedEvent event = new JobCreatedEvent(saved.getId(), saved.getTitle());
        kafkaTemplate.send("job.created", event);

        return saved;
    }

    /**
     * Gets a job by its ID.
     */
    public Job getJobById(String jobId) {
        return jobRepository.findById(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found: " + jobId));
    }

    /**
     * Updates the status of a job.
     */
    @Transactional
    public Job updateJobStatus(String jobId, Job.JobStatus status) {
        Job job = getJobById(jobId);
        job.setStatus(status);
        return jobRepository.save(job);
    }

    /**
     * Gets all jobs for a specific requester.
     */
    public List<Job> getJobsByRequesterId(String requesterId) {
        return jobRepository.findByRequesterId(requesterId);
    }

    /**
     * Gets all jobs with a specific status.
     */
    public List<Job> getJobsByStatus(Job.JobStatus status) {
        return jobRepository.findByStatus(status);
    }

    /**
     * Gets all open jobs (for providers to browse).
     */
    public List<Job> getOpenJobs() {
        return jobRepository.findByStatus(Job.JobStatus.OPEN);
    }

    /**
     * Gets all jobs.
     */
    public List<Job> getAllJobs() {
        return jobRepository.findAll();
    }

    /**
     * Updates a job (full update).
     */
    @Transactional
    public Job updateJob(String jobId, Job jobUpdate) {
        Job job = getJobById(jobId);

        if (jobUpdate.getTitle() != null) {
            job.setTitle(jobUpdate.getTitle());
        }
        if (jobUpdate.getDescription() != null) {
            job.setDescription(jobUpdate.getDescription());
        }
        if (jobUpdate.getBudget() != null) {
            job.setBudget(jobUpdate.getBudget());
        }
        if (jobUpdate.getCurrency() != null) {
            job.setCurrency(jobUpdate.getCurrency());
        }
        if (jobUpdate.getLocation() != null) {
            job.setLocation(jobUpdate.getLocation());
        }
        if (jobUpdate.getDeadline() != null) {
            job.setDeadline(jobUpdate.getDeadline());
        }
        if (jobUpdate.getRequiredSkills() != null) {
            job.setRequiredSkills(jobUpdate.getRequiredSkills());
        }

        return jobRepository.save(job);
    }

    /**
     * Deletes a job.
     */
    @Transactional
    public void deleteJob(String jobId) {
        Job job = getJobById(jobId);
        jobRepository.delete(job);
    }

    /**
     * Search jobs by title or description containing a keyword.
     */
    public List<Job> searchJobs(String keyword) {
        return jobRepository.findByTitleContainingIgnoreCaseOrDescriptionContainingIgnoreCase(keyword, keyword);
    }

    // ==================== CATEGORY METHODS ====================

    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }

    public Category createCategory(Category category) {
        return categoryRepository.save(category);
    }

    // ==================== APPLICATION METHODS ====================

    @Transactional
    public JobApplication applyForJob(JobApplication application) {
        // Check if job exists
        getJobById(application.getJobId());

        // Check if already applied
        applicationRepository.findByJobIdAndProviderId(application.getJobId(), application.getProviderId())
                .ifPresent(a -> {
                    throw new RuntimeException("Already applied for this job");
                });

        return applicationRepository.save(application);
    }

    public List<JobApplication> getApplicationsByJob(String jobId) {
        return applicationRepository.findByJobId(jobId);
    }

    public List<JobApplication> getApplicationsByProvider(String providerId) {
        return applicationRepository.findByProviderId(providerId);
    }

    @Transactional
    public JobApplication updateApplicationStatus(String applicationId, JobApplication.ApplicationStatus status) {
        JobApplication application = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Application not found"));
        application.setStatus(status);
        return applicationRepository.save(application);
    }
}