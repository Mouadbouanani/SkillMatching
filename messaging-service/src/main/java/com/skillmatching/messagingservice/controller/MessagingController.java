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
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.CompletableFuture;

@RestController
@RequestMapping
@CrossOrigin(origins = "*")
public class MessagingController {

    @Autowired
    private MessagingService messagingService;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    // ==================== REST ENDPOINTS ====================

    @PostMapping("/send")
    public CompletableFuture<ResponseEntity<Message>> sendMessageRest(@RequestBody Message message) {
        System.out.println("📩 Received message to send: " + message.getText() + " from: " + message.getFromId()
                + " in conv: " + message.getConversationId());
        return messagingService.sendMessage(message)
                .thenApply(documentRef -> {
                    message.setId(documentRef.getId());
                    // Broadcast to WebSocket subscribers as well
                    try {
                        messagingTemplate.convertAndSend("/topic/conversation/" + message.getConversationId(), message);
                    } catch (Exception e) {
                        System.err.println("WebSocket broadcast failed: " + e.getMessage());
                    }
                    return ResponseEntity.ok(message);
                });
    }

    @GetMapping("/conversation/{conversationId}")
    public CompletableFuture<ResponseEntity<List<Message>>> getConversationMessagesRest(
            @PathVariable String conversationId) {
        return messagingService.getConversationMessages(conversationId)
                .thenApply(ResponseEntity::ok);
    }

    @PutMapping("/{messageId}/read")
    public CompletableFuture<ResponseEntity<Message>> markAsReadRest(@PathVariable String messageId) {
        return messagingService.markAsRead(messageId)
                .thenApply(updatedMessage -> {
                    if (updatedMessage != null) {
                        return ResponseEntity.ok(updatedMessage);
                    } else {
                        return ResponseEntity.notFound().build();
                    }
                });
    }

    @GetMapping("/conversations")
    public CompletableFuture<ResponseEntity<List<com.skillmatching.messagingservice.entity.Conversation>>> getUserConversations(
            @RequestParam String userId) {
        // In a real app, userId should come from authentication token
        return messagingService.getUserConversations(userId)
                .thenApply(ResponseEntity::ok);
    }

    @PostMapping("/conversations")
    public CompletableFuture<ResponseEntity<com.skillmatching.messagingservice.entity.Conversation>> createConversation(
            @RequestBody com.skillmatching.messagingservice.entity.Conversation conversation) {
        return messagingService.createConversation(conversation)
                .thenApply(documentRef -> {
                    conversation.setId(documentRef.getId());
                    return ResponseEntity.ok(conversation);
                });
    }

    @GetMapping("/actuator/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Messaging Service is UP");
    }

    // ==================== WEBSOCKET ENDPOINTS ====================

    @MessageMapping("/chat/{conversationId}")
    public void sendMessageWebSocket(@DestinationVariable String conversationId, @Payload Message message) {
        messagingService.sendMessage(message)
                .thenAccept(documentRef -> {
                    try {
                        message.setId(documentRef.getId());
                        messagingTemplate.convertAndSend("/topic/conversation/" + conversationId, message);
                    } catch (Exception e) {
                        System.err.println("Error sending message via WebSocket: " + e.getMessage());
                    }
                });
    }
}