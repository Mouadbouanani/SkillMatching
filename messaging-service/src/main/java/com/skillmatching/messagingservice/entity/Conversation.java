package com.skillmatching.messagingservice.entity;

import lombok.*;
import javax.annotation.PostConstruct;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Conversation {

    private String id;

    private String matchId;

    private String participant1Id;

    private String participant2Id;

    private LocalDateTime lastMessageAt;

    private LocalDateTime createdAt;

    // Explicit getters and setters to ensure compatibility
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getMatchId() { return matchId; }
    public void setMatchId(String matchId) { this.matchId = matchId; }

    public String getParticipant1Id() { return participant1Id; }
    public void setParticipant1Id(String participant1Id) { this.participant1Id = participant1Id; }

    public String getParticipant2Id() { return participant2Id; }
    public void setParticipant2Id(String participant2Id) { this.participant2Id = participant2Id; }

    public LocalDateTime getLastMessageAt() { return lastMessageAt; }
    public void setLastMessageAt(LocalDateTime lastMessageAt) { this.lastMessageAt = lastMessageAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) {
        if(this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        } else {
            this.createdAt = createdAt;
        }
    }

    @PostConstruct
    public void init() {
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
    }
}
