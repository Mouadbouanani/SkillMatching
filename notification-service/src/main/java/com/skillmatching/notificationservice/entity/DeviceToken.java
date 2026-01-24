package com.skillmatching.notificationservice.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Date;

/**
 * POJO to store FCM device tokens for users in Firestore.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DeviceToken {
    private String id;
    private String userId;
    private String token;
    private String deviceType;
    private Date createdAt;
    private Date updatedAt;
    private Boolean isActive = true;
}
