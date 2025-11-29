package com.skillmatching.notificationservice.controller;

import com.skillmatching.notificationservice.service.FirebaseNotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping
@CrossOrigin(origins = "*")
public class NotificationController {

    @Autowired
    private FirebaseNotificationService notificationService;

    @PostMapping("/send")
    public ResponseEntity<?> sendNotification(
            @RequestParam String deviceToken,
            @RequestParam String title,
            @RequestParam String body) {
        notificationService.sendNotification(deviceToken, title, body);
        return ResponseEntity.ok("Notification sent");
    }
}