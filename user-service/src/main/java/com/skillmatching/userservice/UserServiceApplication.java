package com.skillmatching.userservice;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.io.FileInputStream;
import java.io.IOException;

@SpringBootApplication
public class UserServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(UserServiceApplication.class, args);
	}
	@Bean
	public FirebaseApp firebaseApp() throws IOException {
		FileInputStream serviceAccount =
				new FileInputStream("src/main/resources/firebase-service-account.json");

		FirebaseOptions options = FirebaseOptions.builder()
				.setCredentials(GoogleCredentials.fromStream(serviceAccount))
				.build();

		// If already initialized, just return it
		if (FirebaseApp.getApps().isEmpty()) {
			return FirebaseApp.initializeApp(options);
		}
		return FirebaseApp.getInstance();
	}
}
