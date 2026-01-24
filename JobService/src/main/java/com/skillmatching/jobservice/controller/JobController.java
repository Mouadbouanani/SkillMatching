package com.skillmatching.jobservice.controller;

import com.skillmatching.jobservice.entity.Category;
import com.skillmatching.jobservice.entity.Job;
import com.skillmatching.jobservice.entity.JobApplication;
import com.skillmatching.jobservice.service.JobService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping
@CrossOrigin(origins = "*")
public class JobController {

    @Autowired
    private JobService jobService;

    // ==================== JOB ENDPOINTS ====================

    /**
     * Create a new job.
     * POST /api/jobs/create
     */
    @PostMapping("/create")
    public ResponseEntity<?> createJob(@RequestBody Job job, Authentication authentication) {
        String uid = authentication.getName(); // Firebase UID
        job.setRequesterId(uid);

        Job created = jobService.createJob(job);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /**
     * Get a job by ID.
     * GET /api/jobs/{jobId}
     */
    @GetMapping("/{jobId}")
    public ResponseEntity<?> getJob(@PathVariable String jobId) {
        try {
            Job job = jobService.getJobById(jobId);
            return ResponseEntity.ok(job);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Job not found: " + jobId);
        }
    }

    /**
     * Get all jobs (for browsing).
     * GET /api/jobs
     */
    @GetMapping
    public ResponseEntity<List<Job>> getAllJobs() {
        return ResponseEntity.ok(jobService.getAllJobs());
    }

    /**
     * Get open jobs (for providers).
     * GET /api/jobs/open
     */
    @GetMapping("/open")
    public ResponseEntity<List<Job>> getOpenJobs() {
        return ResponseEntity.ok(jobService.getOpenJobs());
    }

    /**
     * Get jobs by requester (for clients to view their own jobs).
     * GET /api/jobs/requester/{requesterId}
     */
    @GetMapping("/requester/{requesterId}")
    public ResponseEntity<List<Job>> getJobsByRequester(@PathVariable String requesterId) {
        return ResponseEntity.ok(jobService.getJobsByRequesterId(requesterId));
    }

    /**
     * Get current user's jobs.
     * GET /api/jobs/my
     */
    @GetMapping("/my")
    public ResponseEntity<List<Job>> getMyJobs(Authentication authentication) {
        String uid = authentication.getName();
        return ResponseEntity.ok(jobService.getJobsByRequesterId(uid));
    }

    /**
     * Get jobs matching provider's skills.
     * GET /api/jobs/provider
     */
    @GetMapping("/provider")
    public ResponseEntity<List<Job>> getJobsForProvider(Authentication authentication) {
        // This would typically involve calling ProfileService to get skills,
        // then searching jobs. For now, we return open jobs.
        // In a real AI system, this would call the MatchingService.
        return ResponseEntity.ok(jobService.getOpenJobs());
    }

    /**
     * Get jobs the provider has applied for.
     * GET /api/jobs/provider/applied
     */
    @GetMapping("/provider/applied")
    public ResponseEntity<List<JobApplication>> getAppliedJobs(Authentication authentication) {
        return ResponseEntity.ok(jobService.getApplicationsByProvider(authentication.getName()));
    }

    /**
     * Get jobs assigned to the provider (Assigned = Application Accepted).
     * GET /api/jobs/provider/assigned
     */
    @GetMapping("/provider/assigned")
    public ResponseEntity<List<JobApplication>> getAssignedJobs(Authentication authentication) {
        List<JobApplication> apps = jobService.getApplicationsByProvider(authentication.getName());
        List<JobApplication> assigned = apps.stream()
                .filter(a -> a.getStatus() == JobApplication.ApplicationStatus.ACCEPTED)
                .collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(assigned);
    }

    /**
     * Update job status.
     * PUT /api/jobs/{jobId}/status
     */
    @PutMapping("/{jobId}/status")
    public ResponseEntity<?> updateJobStatus(
            @PathVariable String jobId,
            @RequestParam Job.JobStatus status,
            Authentication authentication) {

        // Verify ownership or admin
        Job job = jobService.getJobById(jobId);
        String uid = authentication.getName();

        if (!job.getRequesterId().equals(uid)) {
            boolean isAdmin = authentication.getAuthorities().stream()
                    .anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"));
            if (!isAdmin) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("You can only update status of your own jobs");
            }
        }

        Job updated = jobService.updateJobStatus(jobId, status);
        return ResponseEntity.ok(updated);
    }

    /**
     * Update job details.
     * PUT /api/jobs/{jobId}
     */
    @PutMapping("/{jobId}")
    public ResponseEntity<?> updateJob(
            @PathVariable String jobId,
            @RequestBody Job jobUpdate,
            Authentication authentication) {

        // Verify ownership
        Job job = jobService.getJobById(jobId);
        String uid = authentication.getName();

        if (!job.getRequesterId().equals(uid)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("You can only update your own jobs");
        }

        Job updated = jobService.updateJob(jobId, jobUpdate);
        return ResponseEntity.ok(updated);
    }

    /**
     * Delete a job.
     * DELETE /api/jobs/{jobId}
     */
    @DeleteMapping("/{jobId}")
    public ResponseEntity<?> deleteJob(
            @PathVariable String jobId,
            Authentication authentication) {

        // Verify ownership or admin
        Job job = jobService.getJobById(jobId);
        String uid = authentication.getName();

        if (!job.getRequesterId().equals(uid)) {
            boolean isAdmin = authentication.getAuthorities().stream()
                    .anyMatch(auth -> auth.getAuthority().equals("ROLE_ADMIN"));
            if (!isAdmin) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("You can only delete your own jobs");
            }
        }

        jobService.deleteJob(jobId);
        return ResponseEntity.ok("Job deleted successfully");
    }

    /**
     * Search jobs by keyword.
     * GET /api/jobs/search?q=keyword
     */
    @GetMapping("/search")
    public ResponseEntity<List<Job>> searchJobs(@RequestParam String q) {
        return ResponseEntity.ok(jobService.searchJobs(q));
    }

    /**
     * Health check.
     * GET /api/jobs/health
     */
    @GetMapping("/health")
    public ResponseEntity<?> health() {
        return ResponseEntity.ok("Job Service is UP");
    }

    // ==================== CATEGORY ENDPOINTS ====================

    @GetMapping("/categories")
    public ResponseEntity<List<Category>> getAllCategories() {
        return ResponseEntity.ok(jobService.getAllCategories());
    }

    @PostMapping("/categories")
    public ResponseEntity<Category> createCategory(@RequestBody Category category) {
        return ResponseEntity.status(HttpStatus.CREATED).body(jobService.createCategory(category));
    }

    // ==================== APPLICATION ENDPOINTS ====================

    /**
     * Submit an application for a job.
     * POST /api/jobs/apply
     */
    @PostMapping("/apply")
    public ResponseEntity<?> applyForJob(@RequestBody JobApplication application, Authentication authentication) {
        String uid = authentication.getName();
        application.setProviderId(uid);

        try {
            JobApplication created = jobService.applyForJob(application);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    /**
     * Get applications for a specific job (owner only).
     * GET /api/jobs/{jobId}/applications
     */
    @GetMapping("/{jobId}/applications")
    public ResponseEntity<?> getApplicationsByJob(@PathVariable String jobId, Authentication authentication) {
        Job job = jobService.getJobById(jobId);
        if (!job.getRequesterId().equals(authentication.getName())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only job owner can view applications");
        }
        return ResponseEntity.ok(jobService.getApplicationsByJob(jobId));
    }

    /**
     * Get my applications.
     * GET /api/jobs/applications/my
     */
    @GetMapping("/applications/my")
    public ResponseEntity<List<JobApplication>> getMyApplications(Authentication authentication) {
        return ResponseEntity.ok(jobService.getApplicationsByProvider(authentication.getName()));
    }

    /**
     * Update application status (e.g., Accept/Reject).
     * PUT /api/jobs/applications/{applicationId}/status
     */
    @PutMapping("/applications/{applicationId}/status")
    public ResponseEntity<?> updateApplicationStatus(
            @PathVariable String applicationId,
            @RequestParam JobApplication.ApplicationStatus status) {
        return ResponseEntity.ok(jobService.updateApplicationStatus(applicationId, status));
    }
}