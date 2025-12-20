package com.skillmatching.jobservice.service;


import com.skillmatching.jobservice.entity.Job;
import com.skillmatching.jobservice.repository.JobRepository;
import com.skillmatching.jobservice.event.JobCreatedEvent;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class JobService {

    @Autowired
    private JobRepository jobRepository;

    @Autowired
    private KafkaTemplate<String, JobCreatedEvent> kafkaTemplate;

    public Job createJob(Job job) {
        Job saved = jobRepository.save(job);

        // Publish event to Kafka
        JobCreatedEvent event = new JobCreatedEvent(saved.getId(), saved.getTitle());
        kafkaTemplate.send("job.created", event);

        return saved;
    }

    public Job getJobById(String jobId) {
        return jobRepository.findById(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found"));
    }

    public Job updateJobStatus(String jobId, Job.JobStatus status) {
        Job job = getJobById(jobId);
        job.setStatus(status);
        return jobRepository.save(job);
    }
}