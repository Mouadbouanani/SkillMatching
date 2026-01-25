package com.skillmatching.messagingservice.service;

import com.google.cloud.firestore.DocumentReference;
import com.skillmatching.messagingservice.entity.Message;
import com.skillmatching.messagingservice.entity.Conversation;

import java.util.List;
import java.util.concurrent.CompletableFuture;

public interface MessagingServiceInterface {
    CompletableFuture<DocumentReference> sendMessage(Message message);

    CompletableFuture<List<Message>> getConversationMessages(String conversationId);

    CompletableFuture<Message> markAsRead(String messageId);

    // Conversation management
    CompletableFuture<List<Conversation>> getUserConversations(String userId);

    CompletableFuture<DocumentReference> createConversation(Conversation conversation);
}