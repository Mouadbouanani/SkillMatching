package com.skillmatching.matchingservice.listener;

import com.skillmatching.matchingservice.dto.JobCreatedEvent;
import com.skillmatching.matchingservice.service.MatchingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

/**
 * Kafka listener for job-related events.
 * Automatically triggers matching when a new job is created.
 */
@Component
public class JobEventListener {

    private static final Logger logger = LoggerFactory.getLogger(JobEventListener.class);

    @Autowired
    private MatchingService matchingService;

    /**
     * Listens for job.created events from job-service.
     * When a new job is created, automatically trigger the matching process.
     */
    @KafkaListener(topics = "job.created", groupId = "${spring.kafka.consumer.group-id:matching-service-group}", containerFactory = "jobEventKafkaListenerContainerFactory")
    public void handleJobCreated(JobCreatedEvent event) {
        logger.info("Received job.created event: jobId={}, title={}", event.getJobId(), event.getTitle());

        try {
            matchingService.createMatches(event.getJobId());
            logger.info("Successfully created matches for job: {}", event.getJobId());
        } catch (Exception e) {
            logger.error("Failed to create matches for job {}: {}", event.getJobId(), e.getMessage(), e);
            // In production, you might want to send this to a dead-letter queue
        }
    }
}
