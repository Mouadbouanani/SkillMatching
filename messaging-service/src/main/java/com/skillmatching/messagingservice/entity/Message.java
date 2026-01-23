package com.skillmatching.messagingservice.entity;

import lombok.*;
import javax.annotation.PostConstruct;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Message {

    private String id;

    private String conversationId;

    private String fromId;

    private String toId;

    private String text;

    private String metadata;

    private Boolean isRead;

    private LocalDateTime readAt;

    private LocalDateTime sentAt;

    private TypeMessage type;

    // Explicit getters and setters to ensure compatibility
    public String getId() { return id; }
    public void setId(String id) {
        this.id = id;
    }

    public String getConversationId() { return conversationId; }
    public void setConversationId(String conversationId) { this.conversationId = conversationId; }

    public String getFromId() { return fromId; }
    public void setFromId(String fromId) { this.fromId = fromId; }

    public String getToId() { return toId; }
    public void setToId(String toId) { this.toId = toId; }

    public String getText() { return text; }
    public void setText(String text) { this.text = text; }

    public String getMetadata() { return metadata; }
    public void setMetadata(String metadata) { this.metadata = metadata; }

    public Boolean getIsRead() { return isRead; }
    public void setIsRead(Boolean isRead) { this.isRead = isRead; }

    public LocalDateTime getReadAt() { return readAt; }
    public void setReadAt(LocalDateTime readAt) { this.readAt = readAt; }

    public LocalDateTime getSentAt() { return sentAt; }
    public void setSentAt(LocalDateTime sentAt) {
        if(this.sentAt == null) {
            this.sentAt = LocalDateTime.now();
        } else {
            this.sentAt = sentAt;
        }
    }

    public TypeMessage getType() { return type; }
    public void setType(TypeMessage type) { this.type = type; }

    @PostConstruct
    public void init() {
        if (this.sentAt == null) {
            this.sentAt = LocalDateTime.now();
        }
        if (this.isRead == null) {
            this.isRead = false;
        }
    }
}