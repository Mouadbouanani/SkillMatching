package com.skillmatching.notificationservice.service;

import com.google.cloud.firestore.*;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.skillmatching.notificationservice.dto.JobCreatedEvent;
import com.skillmatching.notificationservice.dto.MatchCreatedEvent;
import com.skillmatching.notificationservice.entity.DeviceToken;
import com.skillmatching.notificationservice.entity.Notification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutionException;

/**
 * Service for sending notifications via FCM and storing them in Firestore.
 */
@Service
public class FirebaseNotificationService {

    private static final Logger logger = LoggerFactory.getLogger(FirebaseNotificationService.class);

    @Autowired
    private Firestore firestore;

    private static final String NOTIFICATIONS_COLLECTION = "notifications";
    private static final String DEVICE_TOKENS_COLLECTION = "device_tokens";

    // ==================== PUSH NOTIFICATION METHODS ====================

    public void sendNotification(String deviceToken, String title, String body) {
        try {
            Message message = Message.builder()
                    .setToken(deviceToken)
                    .setNotification(com.google.firebase.messaging.Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .build();

            String response = FirebaseMessaging.getInstance().send(message);
            logger.info("Notification sent successfully: {}", response);
        } catch (Exception e) {
            logger.error("Failed to send notification: {}", e.getMessage());
            if (e.getMessage() != null && e.getMessage().contains("Requested entity was not found")) {
                deactivateToken(deviceToken);
            }
        }
    }

    public void sendNotificationToUser(String userId, String title, String body,
            Notification.NotificationType type, String referenceId) {
        // Create Notification record
        Notification notification = new Notification();
        notification.setId(UUID.randomUUID().toString());
        notification.setUserId(userId);
        notification.setTitle(title);
        notification.setBody(body);
        notification.setType(type.name());
        notification.setReferenceId(referenceId);
        notification.setIsRead(false);
        notification.setIsSent(false);
        notification.setCreatedAt(new Date());

        // Get active device tokens for user from Firestore
        List<DeviceToken> tokens = getActiveTokensForUser(userId);

        if (tokens.isEmpty()) {
            logger.warn("No active device tokens found for user: {}", userId);
            saveNotification(notification);
            return;
        }

        boolean anySent = false;
        for (DeviceToken token : tokens) {
            String tokenValue = token.getToken();
            if (tokenValue != null && !tokenValue.isEmpty()) {
                try {
                    sendNotification(tokenValue, title, body);
                    anySent = true;
                } catch (Exception e) {
                    logger.error("Failed to send to token {}: {}", tokenValue, e.getMessage());
                }
            }
        }

        if (anySent) {
            notification.setIsSent(true);
        }
        saveNotification(notification);
    }

    // ==================== FIRESTORE PERSISTENCE METHODS ====================

    private void saveNotification(Notification notification) {
        String id = notification.getId();
        if (id != null) {
            firestore.collection(NOTIFICATIONS_COLLECTION).document(id).set(notification);
        } else {
            logger.error("Cannot save notification with null ID");
        }
    }

    private List<DeviceToken> getActiveTokensForUser(String userId) {
        List<DeviceToken> tokens = new ArrayList<>();
        try {
            QuerySnapshot snapshot = firestore.collection(DEVICE_TOKENS_COLLECTION)
                    .whereEqualTo("userId", userId)
                    .whereEqualTo("isActive", true)
                    .get().get();
            for (QueryDocumentSnapshot doc : snapshot) {
                tokens.add(doc.toObject(DeviceToken.class));
            }
        } catch (InterruptedException | ExecutionException e) {
            logger.error("Error fetching device tokens: {}", e.getMessage());
            Thread.currentThread().interrupt();
        }
        return tokens;
    }

    public DeviceToken registerDeviceToken(String userId, String token, String deviceType) {
        DeviceToken deviceToken = new DeviceToken();
        try {
            QuerySnapshot snapshot = firestore.collection(DEVICE_TOKENS_COLLECTION)
                    .whereEqualTo("token", token)
                    .get().get();

            if (!snapshot.isEmpty()) {
                DocumentSnapshot doc = snapshot.getDocuments().get(0);
                DeviceToken existingToken = doc.toObject(DeviceToken.class);
                if (existingToken != null) {
                    deviceToken = existingToken;
                    deviceToken.setUserId(userId);
                    deviceToken.setIsActive(true);
                    deviceToken.setUpdatedAt(new Date());
                    doc.getReference().set(deviceToken);
                }
            } else {
                deviceToken.setId(UUID.randomUUID().toString());
                deviceToken.setUserId(userId);
                deviceToken.setToken(token);
                deviceToken.setDeviceType(deviceType);
                deviceToken.setIsActive(true);
                deviceToken.setCreatedAt(new Date());
                deviceToken.setUpdatedAt(new Date());
                String id = deviceToken.getId();
                if (id != null) {
                    firestore.collection(DEVICE_TOKENS_COLLECTION).document(id).set(deviceToken);
                }
            }
        } catch (InterruptedException | ExecutionException e) {
            logger.error("Error registering device token: {}", e.getMessage());
            Thread.currentThread().interrupt();
        }
        return deviceToken;
    }

    public void deactivateToken(String token) {
        try {
            QuerySnapshot snapshot = firestore.collection(DEVICE_TOKENS_COLLECTION)
                    .whereEqualTo("token", token)
                    .get().get();
            for (QueryDocumentSnapshot doc : snapshot) {
                doc.getReference().update("isActive", false, "updatedAt", new Date());
                logger.info("Deactivated token: {}", token);
            }
        } catch (InterruptedException | ExecutionException e) {
            logger.error("Error deactivating token: {}", e.getMessage());
        }
    }

    public List<Notification> getNotificationsForUser(String userId) {
        List<Notification> result = new ArrayList<>();
        try {
            QuerySnapshot snapshot = firestore.collection(NOTIFICATIONS_COLLECTION)
                    .whereEqualTo("userId", userId)
                    .orderBy("createdAt", Query.Direction.DESCENDING)
                    .get().get();
            for (QueryDocumentSnapshot doc : snapshot) {
                result.add(doc.toObject(Notification.class));
            }
        } catch (InterruptedException | ExecutionException e) {
            logger.error("Error fetching notifications: {}", e.getMessage());
        }
        return result;
    }

    public List<Notification> getUnreadNotifications(String userId) {
        List<Notification> result = new ArrayList<>();
        try {
            QuerySnapshot snapshot = firestore.collection(NOTIFICATIONS_COLLECTION)
                    .whereEqualTo("userId", userId)
                    .whereEqualTo("isRead", false)
                    .orderBy("createdAt", Query.Direction.DESCENDING)
                    .get().get();
            for (QueryDocumentSnapshot doc : snapshot) {
                result.add(doc.toObject(Notification.class));
            }
        } catch (InterruptedException | ExecutionException e) {
            logger.error("Error fetching unread notifications: {}", e.getMessage());
        }
        return result;
    }

    public void markAsRead(String notificationId) {
        firestore.collection(NOTIFICATIONS_COLLECTION).document(notificationId)
                .update("isRead", true, "readAt", new Date());
    }

    public void markAllAsRead(String userId) {
        try {
            QuerySnapshot snapshot = firestore.collection(NOTIFICATIONS_COLLECTION)
                    .whereEqualTo("userId", userId)
                    .whereEqualTo("isRead", false)
                    .get().get();
            WriteBatch batch = firestore.batch();
            Date now = new Date();
            for (QueryDocumentSnapshot doc : snapshot) {
                batch.update(doc.getReference(), "isRead", true, "readAt", now);
            }
            batch.commit();
        } catch (InterruptedException | ExecutionException e) {
            logger.error("Error marking all as read: {}", e.getMessage());
        }
    }

    public long getUnreadCount(String userId) {
        try {
            // Firestore doesn't have a direct "count" query easily in Admin SDK without
            // full fetch or aggregate query
            // Aggregate queries are available but for simplicity in this migration:
            return firestore.collection(NOTIFICATIONS_COLLECTION)
                    .whereEqualTo("userId", userId)
                    .whereEqualTo("isRead", false)
                    .get().get().size();
        } catch (InterruptedException | ExecutionException e) {
            logger.error("Error counting unread: {}", e.getMessage());
            return 0;
        }
    }

    // ==================== KAFKA EVENT HANDLERS ====================

    @KafkaListener(topics = "job.created", groupId = "notification-service-group")
    public void handleJobCreated(JobCreatedEvent event) {
        logger.info("Received job.created event: jobId={}, title={}", event.getJobId(), event.getTitle());
    }

    @KafkaListener(topics = "match.created", groupId = "notification-service-group")
    public void handleMatchCreated(MatchCreatedEvent event) {
        logger.info("Received match.created event: matchId={}, jobId={}, providerId={}",
                event.getMatchId(), event.getJobId(), event.getProviderId());

        String title = "New Job Match!";
        String body = String.format("You've been matched with '%s' (Score: %.0f%%)",
                event.getJobTitle(), event.getMatchScore());

        sendNotificationToUser(
                event.getProviderId(),
                title,
                body,
                Notification.NotificationType.MATCH_FOUND,
                event.getMatchId());
    }
}