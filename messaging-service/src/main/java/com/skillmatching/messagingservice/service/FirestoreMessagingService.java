package com.skillmatching.messagingservice.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.skillmatching.messagingservice.entity.Message;
import com.skillmatching.messagingservice.entity.Conversation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.function.Consumer;

@Service
public class FirestoreMessagingService implements MessagingServiceInterface {

    private final Firestore firestore;
    private final SimpMessagingTemplate messagingTemplate;

    private CollectionReference messagesCollection;
    private CollectionReference conversationsCollection;
    private boolean isFirestoreAvailable = false;

    @Autowired
    public FirestoreMessagingService(Firestore firestore, SimpMessagingTemplate messagingTemplate) {
        this.firestore = firestore;
        this.messagingTemplate = messagingTemplate;
    }

    @PostConstruct
    public void init() {
        try {
            if (firestore != null) {
                this.messagesCollection = firestore.collection("messages");
                this.conversationsCollection = firestore.collection("conversations");
                this.isFirestoreAvailable = true;
                System.out.println("✅ Firestore initialized successfully in MessagingService");
            } else {
                System.err.println("❌ Firestore instance is NULL. Check FirebaseConfig.");
            }
        } catch (Exception e) {
            System.err.println("❌ Error initializing Firestore collections: " + e.getMessage());
        }
    }

    @Override
    public CompletableFuture<DocumentReference> sendMessage(Message message) {
        CompletableFuture<DocumentReference> future = new CompletableFuture<>();
        if (!isFirestoreAvailable) {
            future.completeExceptionally(new RuntimeException("Firestore not available"));
            return future;
        }

        if (message.getSentAt() == null) {
            message.setSentAt(new java.util.Date());
        }
        if (message.getIsRead() == null) {
            message.setIsRead(false);
        }

        ApiFuture<DocumentReference> apiFuture = messagesCollection.add(message);
        apiFuture.addListener(() -> {
            try {
                DocumentReference ref = apiFuture.get();
                updateConversationLastMessage(message.getConversationId(), message.getText());
                future.complete(ref);
            } catch (Exception e) {
                System.err.println("❌ Error sending message: " + e.getMessage());
                future.completeExceptionally(e);
            }
        }, Runnable::run);

        return future;
    }

    private void updateConversationLastMessage(String conversationId, String content) {
        if (conversationId == null)
            return;
        try {
            conversationsCollection.document(conversationId).update(
                    "lastMessageContent", content,
                    "lastMessageAt", FieldValue.serverTimestamp());
        } catch (Exception e) {
            System.err.println("⚠️ Could not update conversation last message: " + e.getMessage());
        }
    }

    @Override
    public CompletableFuture<List<Message>> getConversationMessages(String conversationId) {
        CompletableFuture<List<Message>> future = new CompletableFuture<>();
        if (!isFirestoreAvailable) {
            future.complete(new ArrayList<>());
            return future;
        }

        System.out.println("🔍 Fetching messages for conversation: " + conversationId);

        // TEMPORARILY disable orderBy to rule out missing index issues
        ApiFuture<QuerySnapshot> apiFuture = messagesCollection
                .whereEqualTo("conversationId", conversationId)
                // .orderBy("sentAt", Query.Direction.ASCENDING)
                .get();

        apiFuture.addListener(() -> {
            try {
                QuerySnapshot querySnapshot = apiFuture.get();
                List<Message> messages = querySnapshot.toObjects(Message.class);
                // Sort manually in memory for now if needed, or just return as is
                messages.sort((m1, m2) -> {
                    if (m1.getSentAt() == null)
                        return -1;
                    if (m2.getSentAt() == null)
                        return 1;
                    return m1.getSentAt().compareTo(m2.getSentAt());
                });
                future.complete(messages);
                System.out.println("✅ Found " + messages.size() + " messages");
            } catch (Exception e) {
                System.err.println("❌ Error getting messages: " + e.getMessage());
                e.printStackTrace();
                future.completeExceptionally(e);
            }
        }, Runnable::run);

        return future;
    }

    @Override
    public CompletableFuture<Message> markAsRead(String messageId) {
        CompletableFuture<Message> future = new CompletableFuture<>();
        DocumentReference docRef = messagesCollection.document(messageId);

        docRef.update("isRead", true, "readAt", FieldValue.serverTimestamp())
                .addListener(() -> {
                    try {
                        DocumentSnapshot snap = docRef.get().get();
                        future.complete(snap.toObject(Message.class));
                    } catch (Exception e) {
                        future.completeExceptionally(e);
                    }
                }, Runnable::run);

        return future;
    }

    @Override
    public CompletableFuture<List<Conversation>> getUserConversations(String userId) {
        CompletableFuture<List<Conversation>> future = new CompletableFuture<>();
        if (!isFirestoreAvailable) {
            future.complete(new ArrayList<>());
            return future;
        }

        System.out.println("🔍 Fetching conversations for user: " + userId);

        ApiFuture<QuerySnapshot> q1Future = conversationsCollection.whereEqualTo("participant1Id", userId).get();
        ApiFuture<QuerySnapshot> q2Future = conversationsCollection.whereEqualTo("participant2Id", userId).get();

        CompletableFuture.runAsync(() -> {
            try {
                QuerySnapshot snap1 = q1Future.get();
                QuerySnapshot snap2 = q2Future.get();

                List<Conversation> list = new ArrayList<>();
                list.addAll(snap1.toObjects(Conversation.class));
                list.addAll(snap2.toObjects(Conversation.class));

                future.complete(deduplicate(list));
                System.out.println("✅ Found " + list.size() + " conversations (before deduplication)");
            } catch (Exception e) {
                System.err.println("❌ Error getting conversations: " + e.getMessage());
                future.completeExceptionally(e);
            }
        });

        return future;
    }

    private List<Conversation> deduplicate(List<Conversation> list) {
        java.util.Map<String, Conversation> map = new java.util.HashMap<>();
        for (Conversation c : list) {
            String id = c.getId() != null ? c.getId() : c.getMatchId();
            if (id != null)
                map.put(id, c);
        }
        return new ArrayList<>(map.values());
    }

    @Override
    public CompletableFuture<DocumentReference> createConversation(Conversation conversation) {
        CompletableFuture<DocumentReference> future = new CompletableFuture<>();
        if (!isFirestoreAvailable) {
            future.completeExceptionally(new RuntimeException("Firestore not available"));
            return future;
        }

        ApiFuture<QuerySnapshot> checkFuture = conversationsCollection
                .whereEqualTo("matchId", conversation.getMatchId()).get();

        checkFuture.addListener(() -> {
            try {
                QuerySnapshot snap = checkFuture.get();
                if (!snap.isEmpty()) {
                    future.complete(snap.getDocuments().get(0).getReference());
                } else {
                    ApiFuture<DocumentReference> addFuture = conversationsCollection.add(conversation);
                    future.complete(addFuture.get());
                }
            } catch (Exception e) {
                future.completeExceptionally(e);
            }
        }, Runnable::run);

        return future;
    }

    public void listenForNewMessages(String conversationId, Consumer<Message> onMessage) {
        if (!isFirestoreAvailable)
            return;

        messagesCollection.whereEqualTo("conversationId", conversationId)
                .orderBy("sentAt", Query.Direction.DESCENDING)
                .limit(1)
                .addSnapshotListener((snapshots, e) -> {
                    if (e != null || snapshots == null || snapshots.isEmpty())
                        return;
                    for (DocumentChange dc : snapshots.getDocumentChanges()) {
                        if (dc.getType() == DocumentChange.Type.ADDED) {
                            onMessage.accept(dc.getDocument().toObject(Message.class));
                        }
                    }
                });
    }
}