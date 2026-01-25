package com.skillmatching.messagingservice.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.cloud.firestore.annotation.IgnoreExtraProperties;
import com.google.cloud.firestore.annotation.PropertyName;
import lombok.*;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties(ignoreUnknown = true)
@IgnoreExtraProperties
public class Message {

    private String id;

    @JsonProperty("conversationId")
    private String conversationId;

    @JsonProperty("fromId")
    private String fromId;

    @JsonProperty("toId")
    private String toId;

    @JsonProperty("text")
    private String text;

    private String metadata;
    private Boolean isRead;
    private Date readAt;
    private Date sentAt;
    private TypeMessage type;

    @PropertyName("id")
    public String getId() {
        return id;
    }

    @PropertyName("id")
    public void setId(String id) {
        this.id = id;
    }

    @PropertyName("conversationId")
    public String getConversationId() {
        return conversationId;
    }

    @PropertyName("conversationId")
    public void setConversationId(String conversationId) {
        this.conversationId = conversationId;
    }

    @PropertyName("fromId")
    public String getFromId() {
        return fromId;
    }

    @PropertyName("fromId")
    public void setFromId(String fromId) {
        this.fromId = fromId;
    }

    @PropertyName("toId")
    public String getToId() {
        return toId;
    }

    @PropertyName("toId")
    public void setToId(String toId) {
        this.toId = toId;
    }

    @PropertyName("text")
    public String getText() {
        return text;
    }

    @PropertyName("text")
    public void setText(String text) {
        this.text = text;
    }
}