package com.skillmatching.messagingservice.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;

import java.io.IOException;

@Configuration
public class FirebaseConfig {

    @Value("${firebase.credentials-path:classpath:firebase-credentials.json}")
    private String firebaseCredentialsPath;

    @Value("${firebase.project-id:#{null}}")
    private String projectId;

    @Autowired
    private org.springframework.core.io.ResourceLoader resourceLoader;

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        System.out.println("Loading Firebase credentials from: " + firebaseCredentialsPath);
        Resource resource = resourceLoader.getResource(firebaseCredentialsPath);
        FirebaseOptions.Builder optionsBuilder = FirebaseOptions.builder();

        if (resource.exists()) {
            optionsBuilder.setCredentials(GoogleCredentials.fromStream(resource.getInputStream()));
        } else {
            System.err.println("CRITICAL: Firebase credentials file not found at " + firebaseCredentialsPath);
            optionsBuilder.setCredentials(GoogleCredentials.getApplicationDefault());
        }

        if (projectId != null) {
            optionsBuilder.setProjectId(projectId);
        }

        return FirebaseApp.initializeApp(optionsBuilder.build());
    }

    @Bean
    public Firestore firestore(FirebaseApp firebaseApp) {
        return FirestoreClient.getFirestore(firebaseApp);
    }
}