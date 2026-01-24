package com.skillmatching.notificationservice.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Date;

/**
 * POJO to store notification history in Firestore.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Notification {
    private String id;
    private String userId;
    private String title;
    private String body;
    private String type; // Using String instead of Enum for simpler Firestore storage
    private String referenceId;
    private Boolean isRead = false;
    private Boolean isSent = false;
    private Date createdAt;
    private Date readAt;

    public enum NotificationType {
        MATCH_FOUND,
        MATCH_ACCEPTED,
        MATCH_REJECTED,
        NEW_MESSAGE,
        JOB_CREATED,
        JOB_STATUS_UPDATED,
        PROFILE_VIEWED,
        RATING_RECEIVED,
        SYSTEM
    }
}
