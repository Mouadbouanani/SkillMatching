package com.skillmatching.messagingservice.controller;

import com.google.cloud.firestore.DocumentReference;
import com.skillmatching.messagingservice.entity.Message;
import com.skillmatching.messagingservice.service.MessagingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.CompletableFuture;

@Controller
@RequestMapping
@CrossOrigin(origins = "*")
public class MessagingController {

    @Autowired
    private MessagingService messagingService;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat/{conversationId}")
    public void sendMessage(@DestinationVariable String conversationId, @Payload Message message) {
        messagingService.sendMessage(message)
            .thenAccept(documentRef -> {
                try {
                    // Send the message ID back to the conversation topic
                    message.setId(documentRef.getId());
                    messagingTemplate.convertAndSend("/topic/conversation/" + conversationId, message);
                } catch (Exception e) {
                    System.err.println("Error sending message via WebSocket: " + e.getMessage());
                }
            })
            .exceptionally(throwable -> {
                System.err.println("Error sending message: " + throwable.getMessage());
                return null;
            });
    }

    @GetMapping("/conversation/{conversationId}")
    public void getConversation(@PathVariable String conversationId, @RequestParam(required = false) Integer limit) {
        messagingService.getConversationMessages(conversationId)
            .thenAccept(messages -> {
                // Send messages back to the user's private queue
                messagingTemplate.convertAndSendToUser(
                    "currentUser",
                    "/queue/conversation/" + conversationId,
                    messages
                );
            })
            .exceptionally(throwable -> {
                System.err.println("Error retrieving messages: " + throwable.getMessage());
                return null;
            });
    }

    @PutMapping("/{messageId}/read")
    public void markAsRead(@PathVariable String messageId) {
        messagingService.markAsRead(messageId)
            .thenAccept(updatedMessage -> {
                // Optionally broadcast read receipt
                messagingTemplate.convertAndSend("/topic/message/read", updatedMessage);
            })
            .exceptionally(throwable -> {
                System.err.println("Error marking message as read: " + throwable.getMessage());
                return null;
            });
    }
}