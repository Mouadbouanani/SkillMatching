package com.skillmatching.messagingservice.service;

import com.google.cloud.firestore.DocumentReference;
import com.skillmatching.messagingservice.entity.Message;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;

import com.skillmatching.messagingservice.entity.Conversation;

import java.util.List;
import java.util.concurrent.CompletableFuture;

/**
 * Facade service for messaging operations.
 * Delegates to FirestoreMessagingService for actual implementation.
 */
@Service
@Primary
public class MessagingService implements MessagingServiceInterface {

    private final FirestoreMessagingService firestoreMessagingService;

    @Autowired
    public MessagingService(FirestoreMessagingService firestoreMessagingService) {
        this.firestoreMessagingService = firestoreMessagingService;
    }

    @Override
    public CompletableFuture<DocumentReference> sendMessage(Message message) {
        return firestoreMessagingService.sendMessage(message);
    }

    @Override
    public CompletableFuture<List<Message>> getConversationMessages(String conversationId) {
        return firestoreMessagingService.getConversationMessages(conversationId);
    }

    @Override
    public CompletableFuture<Message> markAsRead(String messageId) {
        return firestoreMessagingService.markAsRead(messageId);
    }

    @Override
    public CompletableFuture<List<Conversation>> getUserConversations(String userId) {
        return firestoreMessagingService.getUserConversations(userId);
    }

    @Override
    public CompletableFuture<DocumentReference> createConversation(Conversation conversation) {
        return firestoreMessagingService.createConversation(conversation);
    }
}
