package com.skillmatching.notificationservice.controller;

import com.skillmatching.notificationservice.entity.DeviceToken;
import com.skillmatching.notificationservice.entity.Notification;
import com.skillmatching.notificationservice.service.FirebaseNotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST Controller for notification operations.
 * Base path: /api/notifications (configured in application.yml)
 */
@RestController
@RequestMapping
@CrossOrigin(origins = "*")
public class NotificationController {

    @Autowired
    private FirebaseNotificationService notificationService;

    // ==================== DEVICE TOKEN ENDPOINTS ====================

    /**
     * Register a device token for push notifications.
     * POST /api/notifications/device-token
     */
    @PostMapping("/device-token")
    public ResponseEntity<?> registerDeviceToken(
            @RequestBody Map<String, String> request,
            Authentication authentication) {

        String userId = authentication.getName();
        String token = request.get("token");
        String deviceType = request.getOrDefault("deviceType", "android");

        if (token == null || token.isBlank()) {
            return ResponseEntity.badRequest().body("Token is required");
        }

        DeviceToken saved = notificationService.registerDeviceToken(userId, token, deviceType);
        return ResponseEntity.ok(Map.of(
                "message", "Device token registered successfully",
                "tokenId", saved.getId()));
    }

    /**
     * Deactivate a device token (e.g., on logout).
     * DELETE /api/notifications/device-token
     */
    @DeleteMapping("/device-token")
    public ResponseEntity<?> deactivateDeviceToken(@RequestParam String token) {
        notificationService.deactivateToken(token);
        return ResponseEntity.ok("Device token deactivated");
    }

    // ==================== NOTIFICATION HISTORY ENDPOINTS ====================

    /**
     * Get all notifications for the current user.
     * GET /api/notifications
     */
    @GetMapping
    public ResponseEntity<List<Notification>> getNotifications(Authentication authentication) {
        String userId = authentication.getName();
        return ResponseEntity.ok(notificationService.getNotificationsForUser(userId));
    }

    /**
     * Get unread notifications for the current user.
     * GET /api/notifications/unread
     */
    @GetMapping("/unread")
    public ResponseEntity<List<Notification>> getUnreadNotifications(Authentication authentication) {
        String userId = authentication.getName();
        return ResponseEntity.ok(notificationService.getUnreadNotifications(userId));
    }

    /**
     * Get unread notification count.
     * GET /api/notifications/unread/count
     */
    @GetMapping("/unread/count")
    public ResponseEntity<?> getUnreadCount(Authentication authentication) {
        String userId = authentication.getName();
        return ResponseEntity.ok(Map.of("count", notificationService.getUnreadCount(userId)));
    }

    @PutMapping("/{notificationId}/read")
    public ResponseEntity<?> markAsRead(
            @PathVariable String notificationId,
            Authentication authentication) {
        notificationService.markAsRead(notificationId);
        return ResponseEntity.ok("Notification marked as read");
    }

    /**
     * Mark all notifications as read.
     * PUT /api/notifications/read-all
     */
    @PutMapping("/read-all")
    public ResponseEntity<?> markAllAsRead(Authentication authentication) {
        String userId = authentication.getName();
        notificationService.markAllAsRead(userId);
        return ResponseEntity.ok("All notifications marked as read");
    }

    // ==================== ADMIN/INTERNAL ENDPOINTS ====================

    /**
     * Send a notification to a specific device (admin/internal).
     * POST /api/notifications/send
     */
    @PostMapping("/send")
    public ResponseEntity<?> sendNotification(
            @RequestParam String deviceToken,
            @RequestParam String title,
            @RequestParam String body) {
        notificationService.sendNotification(deviceToken, title, body);
        return ResponseEntity.ok("Notification sent");
    }

    /**
     * Send a notification to a specific user (admin/internal).
     * POST /api/notifications/send/user
     */
    @PostMapping("/send/user")
    public ResponseEntity<?> sendNotificationToUser(
            @RequestParam String userId,
            @RequestParam String title,
            @RequestParam String body,
            @RequestParam(defaultValue = "SYSTEM") String type) {

        Notification.NotificationType notificationType = Notification.NotificationType.valueOf(type.toUpperCase());

        notificationService.sendNotificationToUser(userId, title, body, notificationType, null);
        return ResponseEntity.ok("Notification sent to user");
    }

    /**
     * Health check.
     * GET /api/notifications/health
     */
    @GetMapping("/health")
    public ResponseEntity<?> health() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "notification-service"));
    }
}