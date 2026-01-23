package com.skillmatching.jobservice.event;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class JobCreatedEvent {
    private String jobId;
    private String title;
}