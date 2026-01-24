package com.skillmatching.messagingservice.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;

import java.io.IOException;

@Configuration
public class FirebaseConfig {

    @Value("${firebase.credentials-location:classpath:firebase-credentials.json}")
    private String firebaseCredentialsLocation;

    @Value("${firebase.project-id:#{null}}")
    private String projectId;

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        Resource resource = new ClassPathResource(firebaseCredentialsLocation.replace("classpath:", ""));
        FirebaseOptions.Builder optionsBuilder = FirebaseOptions.builder();

        if (resource.exists()) {
            optionsBuilder.setCredentials(GoogleCredentials.fromStream(resource.getInputStream()));
        } else {
            System.out.println("Firebase credentials file not found, attempting to use default credentials.");
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