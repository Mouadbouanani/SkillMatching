package com.skillmatching.matchingservice.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * Configuration for WebClient beans used for inter-service communication.
 * Each service has its own WebClient configured with the appropriate base URL.
 */
@Configuration
public class WebClientConfig {

    @Value("${services.job-service.url:http://job-service:8083}")
    private String jobServiceUrl;

    @Value("${services.profile-service.url:http://profile-service:8082}")
    private String profileServiceUrl;

    @Value("${services.notification-service.url:http://notification-service:8085}")
    private String notificationServiceUrl;

    /**
     * WebClient for communicating with Job Service.
     */
    @Bean(name = "jobServiceWebClient")
    public WebClient jobServiceWebClient(WebClient.Builder builder) {
        return builder
                .baseUrl(jobServiceUrl)
                .defaultHeader("Content-Type", "application/json")
                .build();
    }

    /**
     * WebClient for communicating with Profile Service.
     */
    @Bean(name = "profileServiceWebClient")
    public WebClient profileServiceWebClient(WebClient.Builder builder) {
        return builder
                .baseUrl(profileServiceUrl)
                .defaultHeader("Content-Type", "application/json")
                .build();
    }

    /**
     * WebClient for communicating with Notification Service.
     */
    @Bean(name = "notificationServiceWebClient")
    public WebClient notificationServiceWebClient(WebClient.Builder builder) {
        return builder
                .baseUrl(notificationServiceUrl)
                .defaultHeader("Content-Type", "application/json")
                .build();
    }

    /**
     * Default WebClient (generic usage).
     */
    @Bean
    public WebClient webClient(WebClient.Builder builder) {
        return builder.build();
    }
}
