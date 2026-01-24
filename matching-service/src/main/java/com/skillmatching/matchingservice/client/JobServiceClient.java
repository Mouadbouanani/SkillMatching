package com.skillmatching.matchingservice.client;

import com.skillmatching.matchingservice.dto.JobDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

/**
 * Client for communicating with job-service via REST.
 */
@Component
public class JobServiceClient {

    private static final Logger logger = LoggerFactory.getLogger(JobServiceClient.class);

    private final WebClient webClient;

    public JobServiceClient(@Qualifier("jobServiceWebClient") WebClient webClient) {
        this.webClient = webClient;
    }

    /**
     * Fetches job details by ID from job-service.
     *
     * @param jobId the job ID
     * @return JobDTO with job details, or null if not found
     */
    public JobDTO getJobById(String jobId) {
        try {
            logger.debug("Fetching job details for jobId: {}", jobId);
            return webClient.get()
                    .uri("/api/jobs/{jobId}", jobId)
                    .retrieve()
                    .bodyToMono(JobDTO.class)
                    .block();
        } catch (WebClientResponseException.NotFound e) {
            logger.warn("Job not found: {}", jobId);
            return null;
        } catch (Exception e) {
            logger.error("Error fetching job {}: {}", jobId, e.getMessage());
            throw new RuntimeException("Failed to fetch job from job-service", e);
        }
    }
}
