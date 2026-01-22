package com.skillmatching.jobservice.controller;

import com.skillmatching.jobservice.entity.Job;
import com.skillmatching.jobservice.service.JobService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping
@CrossOrigin(origins = "*")
public class JobController {

    @Autowired
    private JobService jobService;

    @PostMapping("/create")
    public ResponseEntity<?> createJob(@RequestBody Job job, Authentication authentication) {
        String uid = authentication.getName(); // Firebase UID
        job.setRequesterId(uid);

        Job created = jobService.createJob(job);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping("/{jobId}")
    public ResponseEntity<?> getJob(@PathVariable String jobId) {
        Job job = jobService.getJobById(jobId);
        return ResponseEntity.ok(job);
    }

    @PutMapping("/{jobId}/status")
    public ResponseEntity<?> updateJobStatus(
            @PathVariable String jobId,
            @RequestParam Job.JobStatus status) {
        Job updated = jobService.updateJobStatus(jobId, status);
        return ResponseEntity.ok(updated);
    }
    @GetMapping ("hello")
    public ResponseEntity<?> hello() {
        return ResponseEntity.ok("hello");
    }
}