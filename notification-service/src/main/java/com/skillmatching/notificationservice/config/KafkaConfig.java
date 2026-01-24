package com.skillmatching.notificationservice.config;

import com.skillmatching.notificationservice.dto.JobCreatedEvent;
import com.skillmatching.notificationservice.dto.MatchCreatedEvent;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.support.serializer.JsonDeserializer;

import java.util.HashMap;
import java.util.Map;

/**
 * Kafka consumer configuration for notification-service.
 */
@Configuration
@EnableKafka
public class KafkaConfig {

    @Value("${spring.kafka.bootstrap-servers:localhost:9092}")
    private String bootstrapServers;

    @Value("${spring.kafka.consumer.group-id:notification-service-group}")
    private String groupId;

    /**
     * Common consumer properties.
     */
    private Map<String, Object> consumerProps() {
        Map<String, Object> props = new HashMap<>();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        return props;
    }

    /**
     * Consumer factory for JobCreatedEvent messages.
     */
    @Bean
    public ConsumerFactory<String, JobCreatedEvent> jobEventConsumerFactory() {
        Map<String, Object> props = consumerProps();
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, JsonDeserializer.class);

        JsonDeserializer<JobCreatedEvent> deserializer = new JsonDeserializer<>(JobCreatedEvent.class);
        deserializer.addTrustedPackages("*");
        deserializer.setRemoveTypeHeaders(false);
        deserializer.setUseTypeMapperForKey(true);

        return new DefaultKafkaConsumerFactory<>(props, new StringDeserializer(), deserializer);
    }

    /**
     * Consumer factory for MatchCreatedEvent messages.
     */
    @Bean
    public ConsumerFactory<String, MatchCreatedEvent> matchEventConsumerFactory() {
        Map<String, Object> props = consumerProps();
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, JsonDeserializer.class);

        JsonDeserializer<MatchCreatedEvent> deserializer = new JsonDeserializer<>(MatchCreatedEvent.class);
        deserializer.addTrustedPackages("*");
        deserializer.setRemoveTypeHeaders(false);
        deserializer.setUseTypeMapperForKey(true);

        return new DefaultKafkaConsumerFactory<>(props, new StringDeserializer(), deserializer);
    }

    /**
     * Kafka listener container factory for JobCreatedEvent.
     */
    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, JobCreatedEvent> jobEventKafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, JobCreatedEvent> factory = new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(jobEventConsumerFactory());
        return factory;
    }

    /**
     * Kafka listener container factory for MatchCreatedEvent.
     */
    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, MatchCreatedEvent> matchEventKafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, MatchCreatedEvent> factory = new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(matchEventConsumerFactory());
        return factory;
    }
}
