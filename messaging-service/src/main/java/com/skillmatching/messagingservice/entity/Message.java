package com.skillmatching.messagingservice.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "messages")
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String conversationId;

    @Column(nullable = false)
    private String fromId;

    @Column(nullable = false)
    private String toId;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String text;

    @Column(columnDefinition = "jsonb")
    private String metadata;

    @Column(columnDefinition = "BOOLEAN DEFAULT false")
    private Boolean isRead;

    private LocalDateTime readAt;

    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    private TypeMessage type;


    @PrePersist
    protected void onCreate() {
        sentAt = LocalDateTime.now();
        isRead = false;
    }
}