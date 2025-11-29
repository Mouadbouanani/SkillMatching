package com.skillmatching.messagingservice.config;


import com.skillmatching.messagingservice.entity.Message;
import com.skillmatching.messagingservice.entity.TypeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import java.awt.*;

@Component
@RequiredArgsConstructor
@Slf4j
public class WebSocketEventListener {

    private final SimpMessagingTemplate messagingTemplate;

    @EventListener
    public void handleWebsocketDisconnectListener(
            SessionDisconnectEvent event
    ){
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String username =  headerAccessor.getSessionAttributes().get("username").toString();
        if (username != null) {
            log.info("Disconnected from user: " + username);
            var message = Message.builder()
                    .type(TypeMessage.LEAVE)
                    .toId(username)
                    .build();
            messagingTemplate.convertAndSend("/topic/messages");
        }
    }

}
