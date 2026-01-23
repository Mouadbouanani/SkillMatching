package com.skillmatching.messagingservice.service;

import com.google.cloud.firestore.DocumentReference;
import com.skillmatching.messagingservice.entity.Message;

import java.util.List;
import java.util.concurrent.CompletableFuture;

public interface MessagingServiceInterface {
    CompletableFuture<DocumentReference> sendMessage(Message message);
    CompletableFuture<List<Message>> getConversationMessages(String conversationId);
    CompletableFuture<Message> markAsRead(String messageId);
}