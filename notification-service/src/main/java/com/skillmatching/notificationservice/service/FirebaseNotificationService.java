package com.skillmatching.notificationservice.service;


import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class FirebaseNotificationService {

    private static final Logger logger = LoggerFactory.getLogger(FirebaseNotificationService.class);

    public void sendNotification(String deviceToken, String title, String body) {
        try {
            Message message = Message.builder()
                    .setToken(deviceToken)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            logger.info("Notification sent: {}", response);
        } catch (Exception e) {
            logger.error("Failed to send notification: {}", e.getMessage());
        }
    }

    @KafkaListener(topics = "job.created", groupId = "notification-service-group")
    public void handleJobCreated(String message) {
        logger.info("Job created event received: {}", message);
        // Parse event and send notifications to matching providers
    }

    @KafkaListener(topics = "match.created", groupId = "notification-service-group")
    public void handleMatchCreated(String message) {
        logger.info("Match created event received: {}", message);
        // Send notification to job requester
    }
}