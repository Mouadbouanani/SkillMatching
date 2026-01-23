package com.skillmatching.messagingservice.config;

import com.skillmatching.messagingservice.entity.Message;
import com.skillmatching.messagingservice.entity.TypeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import java.util.HashMap;
import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class WebSocketEventListener {

    private final SimpMessagingTemplate messagingTemplate;

    @EventListener
    public void handleWebSocketConnectListener(SessionConnectEvent event) {
        if (log.isInfoEnabled()) {
            log.info("Received a new web socket connection");
        }
    }

    @EventListener
    public void handleWebSocketConnectedListener(SessionConnectedEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String username = (String) headerAccessor.getSessionAttributes().get("username");
        if (username != null) {
            if (log.isInfoEnabled()) {
                log.info("User connected: " + username);
            }
            // Could broadcast user presence here
        }
    }

    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String username = (String) headerAccessor.getSessionAttributes().get("username");
        if (username != null) {
            if (log.isInfoEnabled()) {
                log.info("User disconnected: " + username);
            }

            // Create and broadcast leave message
            Message leaveMessage = new Message();
            leaveMessage.setType(TypeMessage.LEAVE);
            leaveMessage.setFromId(username);
            leaveMessage.setText(username + " has left the conversation");

            messagingTemplate.convertAndSend("/topic/messages", leaveMessage);
        }
    }
}
