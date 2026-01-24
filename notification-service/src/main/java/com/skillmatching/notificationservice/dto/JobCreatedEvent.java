package com.skillmatching.notificationservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Event received from job-service when a new job is created.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class JobCreatedEvent {
    private String jobId;
    private String title;
}
