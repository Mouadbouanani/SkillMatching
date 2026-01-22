package com.skillmatching.messagingservice.service;

import com.google.cloud.firestore.DocumentReference;
import com.skillmatching.messagingservice.entity.Message;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.concurrent.CompletableFuture;

@Service
public class MessagingService implements MessagingServiceInterface {

    @Autowired
    private MessagingServiceInterface messagingServiceInterface;

    @Override
    public CompletableFuture<DocumentReference> sendMessage(Message message) {
        return messagingServiceInterface.sendMessage(message);
    }

    @Override
    public CompletableFuture<List<Message>> getConversationMessages(String conversationId) {
        return messagingServiceInterface.getConversationMessages(conversationId);
    }

    @Override
    public CompletableFuture<Message> markAsRead(String messageId) {
        return messagingServiceInterface.markAsRead(messageId);
    }
}
