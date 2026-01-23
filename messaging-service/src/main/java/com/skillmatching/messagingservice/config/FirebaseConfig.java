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

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @Value("${firebase.credentials-location:classpath:firebase-credentials.json}")
    private String firebaseCredentialsLocation;

    @Value("${firebase.project-id:#{null}}")
    private String projectId;

    @PostConstruct
    public void initializeFirebase() throws IOException {
        try {
            // Try to load credentials from the specified location
            Resource resource = new ClassPathResource(firebaseCredentialsLocation.replace("classpath:", ""));
            if (resource.exists()) {
                InputStream serviceAccount = resource.getInputStream();

                FirebaseOptions.Builder optionsBuilder = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount));

                if (projectId != null) {
                    optionsBuilder.setProjectId(projectId);
                }

                FirebaseOptions options = optionsBuilder.build();

                if (FirebaseApp.getApps().isEmpty()) {
                    FirebaseApp.initializeApp(options);
                }
            } else {
                // If credentials file doesn't exist, try to initialize with default credentials
                System.out.println("Firebase credentials file not found, attempting to use default credentials.");

                FirebaseOptions.Builder optionsBuilder = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.getApplicationDefault());

                if (projectId != null) {
                    optionsBuilder.setProjectId(projectId);
                }

                FirebaseOptions options = optionsBuilder.build();

                if (FirebaseApp.getApps().isEmpty()) {
                    FirebaseApp.initializeApp(options);
                }
            }
        } catch (IOException e) {
            System.out.println("Could not initialize Firebase: " + e.getMessage());
            System.out.println("Running in development mode without Firebase connection.");
            throw e;
        }
    }

    @Bean
    public Firestore firestore() {
        return FirestoreClient.getFirestore();
    }
}