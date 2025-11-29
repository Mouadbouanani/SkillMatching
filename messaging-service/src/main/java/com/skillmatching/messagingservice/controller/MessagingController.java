package com.skillmatching.messagingservice.controller;


import com.skillmatching.messagingservice.entity.Message;
import com.skillmatching.messagingservice.service.MessagingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping
@CrossOrigin(origins = "*")
public class MessagingController {

    @Autowired
    private MessagingService messagingService;

    @MessageMapping("/send")
    @SendTo("/topic/messages")
    public Message sendMessage(Message message) {
        return messagingService.sendMessage(message);
    }

    @GetMapping("/conversation/{conversationId}")
    public ResponseEntity<?> getConversation(@PathVariable String conversationId) {
        return ResponseEntity.ok(messagingService.getConversationMessages(conversationId));
    }

    @PutMapping("/{messageId}/read")
    public ResponseEntity<?> markAsRead(@PathVariable String messageId) {
        Message updated = messagingService.markAsRead(messageId);
        return ResponseEntity.ok(updated);
    }
}