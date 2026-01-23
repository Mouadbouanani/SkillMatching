package com.skillmatching.profileservice.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.config.EnableMongoAuditing;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

@Configuration
@EnableMongoRepositories(basePackages = "com.skillmatching.profileservice.repository")
@EnableMongoAuditing
public class MongoConfig {
    // MongoDB configuration is handled by application.yml
    // This class enables MongoDB repositories and auditing
}

