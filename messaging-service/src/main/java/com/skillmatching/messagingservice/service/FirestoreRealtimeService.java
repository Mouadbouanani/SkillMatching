package com.skillmatching.messagingservice.service;

import com.google.cloud.firestore.DocumentChange;
import com.google.cloud.firestore.QuerySnapshot;
import com.skillmatching.messagingservice.entity.Message;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;

@Service
public class FirestoreRealtimeService {

    @Autowired
    private FirestoreMessagingService firestoreMessagingService;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @PostConstruct
    public void setupRealtimeListeners() {
        // This would typically be called from a method that sets up listeners for specific conversations
    }

    public void listenForConversationUpdates(String conversationId) {
        firestoreMessagingService.listenForNewMessages(conversationId, message -> {
            // Broadcast the new message to the conversation topic
            messagingTemplate.convertAndSend("/topic/conversation/" + conversationId, message);
        });
    }
}