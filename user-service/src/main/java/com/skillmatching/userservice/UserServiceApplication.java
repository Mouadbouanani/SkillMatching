package com.skillmatching.userservice;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.core.io.ClassPathResource;

import java.io.IOException;
import java.io.InputStream;

@SpringBootApplication
public class UserServiceApplication {


	public static void main(String[] args) {
		SpringApplication.run(UserServiceApplication.class, args);
	}
	@Bean
	public FirebaseApp firebaseApp() throws IOException {
		try {
			InputStream serviceAccount =
					new ClassPathResource("firebase-service-account.json").getInputStream();

			FirebaseOptions options = FirebaseOptions.builder()
					.setCredentials(GoogleCredentials.fromStream(serviceAccount))
					.build();

			// If already initialized, just return it
			if (FirebaseApp.getApps().isEmpty()) {
				return FirebaseApp.initializeApp(options);
			}
			return FirebaseApp.getInstance();
		} catch (Exception e) {
			// Fallback to default credentials if file not found
			FirebaseOptions options = FirebaseOptions.builder()
					.setCredentials(GoogleCredentials.getApplicationDefault())
					.build();

			if (FirebaseApp.getApps().isEmpty()) {
				return FirebaseApp.initializeApp(options);
			}
			return FirebaseApp.getInstance();
		}
	}
}
