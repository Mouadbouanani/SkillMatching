package com.skillmatching.apigeteway.health;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import java.time.Duration;

@Component
public class ServicesHealthIndicator implements HealthIndicator {

    private final WebClient webClient = WebClient.create();

    @Override
    public Health health() {
        try {
            // Check User Service
            checkService("http://user-service:8081/actuator/health", "User Service");
            // Check Profile Service
            checkService("http://profile-service:8082/actuator/health", "Profile Service");
            // Check Job Service
            checkService("http://job-service:8083/actuator/health", "Job Service");
            // Check Matching Service
            checkService("http://matching-service:8084/actuator/health", "Matching Service");
            // Check Notification Service
            checkService("http://notification-service:8085/actuator/health", "Notification Service");
            // Check Messaging Service
            checkService("http://messaging-service:8086/actuator/health", "Messaging Service");

            return Health.up().build();

        } catch (Exception e) {
            return Health.down().withDetail("error", e.getMessage()).build();
        }
    }

    private void checkService(String url, String serviceName) {
        webClient.get()
                .uri(url)
                .retrieve()
                .bodyToMono(String.class)
                .timeout(Duration.ofSeconds(2))
                .block();
    }
}