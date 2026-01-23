package com.skillmatching.messagingservice.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.skillmatching.messagingservice.entity.Message;
import com.skillmatching.messagingservice.entity.TypeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.function.Consumer;

@Service
public class FirestoreMessagingService implements MessagingServiceInterface {

    @Autowired
    @Lazy
    private Firestore firestore;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    private CollectionReference messagesCollection;
    private CollectionReference conversationsCollection;
    private boolean isFirestoreAvailable = true;

    @PostConstruct
    public void init() {
        try {
            // Try to initialize Firestore collections
            if (firestore != null) {
                messagesCollection = firestore.collection("messages");
                conversationsCollection = firestore.collection("conversations");
            } else {
                System.out.println("Firestore is not available. Running in limited mode.");
                isFirestoreAvailable = false;
            }
        } catch (Exception e) {
            System.out.println("Error initializing Firestore: " + e.getMessage());
            isFirestoreAvailable = false;
        }
    }

    @Override
    public CompletableFuture<DocumentReference> sendMessage(Message message) {
        if (!isFirestoreAvailable) {
            return handleWithoutFirestore(message);
        }

        // Set timestamp if not already set
        if (message.getSentAt() == null) {
            message.setSentAt(LocalDateTime.now());
        }
        if (message.getIsRead() == null) {
            message.setIsRead(false);
        }

        // Convert ApiFuture to CompletableFuture
        ApiFuture<DocumentReference> apiFuture = messagesCollection.add(message);

        CompletableFuture<DocumentReference> completableFuture = new CompletableFuture<>();
        apiFuture.addListener(() -> {
            try {
                DocumentReference result = apiFuture.get();
                completableFuture.complete(result);

                // Broadcast to conversation participants via WebSocket
                messagingTemplate.convertAndSend(
                        "/topic/conversation/" + message.getConversationId(), message);
            } catch (Exception e) {
                completableFuture.completeExceptionally(e);
            }
        }, Runnable::run);

        return completableFuture;
    }

    @Override
    public CompletableFuture<List<Message>> getConversationMessages(String conversationId) {
        if (!isFirestoreAvailable) {
            CompletableFuture<List<Message>> future = new CompletableFuture<>();
            future.complete(List.of()); // Return empty list
            return future;
        }

        ApiFuture<QuerySnapshot> apiFuture = messagesCollection
                .whereEqualTo("conversationId", conversationId)
                .orderBy("sentAt", Query.Direction.ASCENDING)
                .get();

        CompletableFuture<List<Message>> completableFuture = new CompletableFuture<>();
        apiFuture.addListener(() -> {
            try {
                QuerySnapshot snapshot = apiFuture.get();
                List<Message> messages = snapshot.toObjects(Message.class);
                completableFuture.complete(messages);
            } catch (Exception e) {
                completableFuture.completeExceptionally(e);
            }
        }, Runnable::run);

        return completableFuture;
    }

    @Override
    public CompletableFuture<Message> markAsRead(String messageId) {
        if (!isFirestoreAvailable) {
            CompletableFuture<Message> future = new CompletableFuture<>();
            Message mockMessage = new Message();
            mockMessage.setId(messageId);
            mockMessage.setIsRead(true);
            mockMessage.setReadAt(LocalDateTime.now());
            future.complete(mockMessage);
            return future;
        }

        DocumentReference messageRef = messagesCollection.document(messageId);

        Message updatedMessage = new Message();
        updatedMessage.setIsRead(true);
        updatedMessage.setReadAt(LocalDateTime.now());

        ApiFuture<WriteResult> apiFuture = messageRef.update("isRead", true, "readAt", LocalDateTime.now());

        CompletableFuture<Message> completableFuture = new CompletableFuture<>();
        apiFuture.addListener(() -> {
            try {
                apiFuture.get(); // Wait for the update to complete
                // Return the updated message
                updatedMessage.setId(messageId);
                completableFuture.complete(updatedMessage);
            } catch (Exception e) {
                completableFuture.completeExceptionally(e);
            }
        }, Runnable::run);

        return completableFuture;
    }

    public void listenForNewMessages(String conversationId, Consumer<Message> callback) {
        if (!isFirestoreAvailable) {
            System.out.println("Firestore not available, cannot listen for new messages");
            return;
        }

        messagesCollection
                .whereEqualTo("conversationId", conversationId)
                .addSnapshotListener((value, error) -> {
                    if (error != null) {
                        System.err.println("Listen failed: " + error);
                        return;
                    }

                    if (value != null) {
                        for (DocumentChange dc : value.getDocumentChanges()) {
                            if (dc.getType() == DocumentChange.Type.ADDED) {
                                Message message = dc.getDocument().toObject(Message.class);
                                message.setId(dc.getDocument().getId());
                                callback.accept(message);
                            }
                        }
                    }
                });
    }

    public CompletableFuture<DocumentReference> createConversation(com.skillmatching.messagingservice.entity.Conversation conversation) {
        if (!isFirestoreAvailable) {
            CompletableFuture<DocumentReference> future = new CompletableFuture<>();
            // Return a completed future with a mock ID (we'll just return a completed future)
            // Since we can't create a real DocumentReference without the complex internal classes
            future.completeExceptionally(new RuntimeException("Firestore not available"));
            return future;
        }

        ApiFuture<DocumentReference> apiFuture = conversationsCollection.add(conversation);

        CompletableFuture<DocumentReference> completableFuture = new CompletableFuture<>();
        apiFuture.addListener(() -> {
            try {
                DocumentReference result = apiFuture.get();
                completableFuture.complete(result);
            } catch (Exception e) {
                completableFuture.completeExceptionally(e);
            }
        }, Runnable::run);

        return completableFuture;
    }

    public CompletableFuture<com.skillmatching.messagingservice.entity.Conversation> getConversation(String conversationId) {
        if (!isFirestoreAvailable) {
            CompletableFuture<com.skillmatching.messagingservice.entity.Conversation> future = new CompletableFuture<>();
            future.complete(null);
            return future;
        }

        ApiFuture<DocumentSnapshot> apiFuture = firestore.collection("conversations")
                .document(conversationId)
                .get();

        CompletableFuture<com.skillmatching.messagingservice.entity.Conversation> completableFuture = new CompletableFuture<>();
        apiFuture.addListener(() -> {
            try {
                DocumentSnapshot snapshot = apiFuture.get();
                if (snapshot.exists()) {
                    com.skillmatching.messagingservice.entity.Conversation conv =
                        snapshot.toObject(com.skillmatching.messagingservice.entity.Conversation.class);
                    conv.setId(snapshot.getId());
                    completableFuture.complete(conv);
                } else {
                    completableFuture.complete(null);
                }
            } catch (Exception e) {
                completableFuture.completeExceptionally(e);
            }
        }, Runnable::run);

        return completableFuture;
    }

    // Helper method to handle operations when Firestore is not available
    private CompletableFuture<DocumentReference> handleWithoutFirestore(Message message) {
        CompletableFuture<DocumentReference> future = new CompletableFuture<>();
        // Return a completed future with a mock ID
        future.completeExceptionally(new RuntimeException("Firestore not available"));

        // Still broadcast to WebSocket for real-time functionality
        messagingTemplate.convertAndSend(
                "/topic/conversation/" + message.getConversationId(), message);

        return future;
    }
}