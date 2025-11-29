package com.skillmatching.messagingservice.service;
import com.skillmatching.messagingservice.entity.Message;
import com.skillmatching.messagingservice.repository.MessageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.data.redis.core.RedisTemplate;
import java.util.List;

@Service
public class MessagingService {

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    public Message sendMessage(Message message) {
        Message saved = messageRepository.save(message);

        // Store in Redis for real-time retrieval
        redisTemplate.opsForList().rightPush(
                "conversation:" + message.getConversationId(),
                saved.getId()
        );

        return saved;
    }

    public List<Message> getConversationMessages(String conversationId) {
        return messageRepository.findByConversationIdOrderBySentAtDesc(conversationId);
    }

    public Message markAsRead(String messageId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new RuntimeException("Message not found"));
        message.setIsRead(true);
        message.setReadAt(java.time.LocalDateTime.now());
        return messageRepository.save(message);
    }
}
