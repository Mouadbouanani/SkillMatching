package com.skillmatching.jobservice.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;

import java.io.IOException;

@Configuration
public class FirebaseConfig {

    @Value("${firebase.credentials-path:classpath:firebase-credentials.json}")
    private Resource credentialsResource;

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (FirebaseApp.getApps().isEmpty()) {
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(credentialsResource.getInputStream()))
                    .setProjectId("skillmatching-86b8d")
                    .build();

            FirebaseApp.initializeApp(options);
            System.out.println("Firebase has been initialized successfully in JobService");
            return FirebaseApp.getInstance();
        }
        return FirebaseApp.getInstance();
    }
}
