package com.skillmatching.userservice.config;

import com.skillmatching.userservice.entity.User;
import com.skillmatching.userservice.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;

@Configuration
public class AdminSeeder {

    @Bean
    public CommandLineRunner seedAdmin(UserRepository userRepository) {
        return args -> {
            String adminUid = "0HjQWzn86HUkhGn5cRKK4VzffJ93";
            String adminEmail = "admin1@gmail.com";

            if (userRepository.findByFirebaseUid(adminUid).isEmpty()) {
                User admin = new User();
                admin.setFirebaseUid(adminUid);
                admin.setEmail(adminEmail);
                admin.setDisplayName("System Admin");
                admin.setRole(User.UserRole.ADMIN);
                admin.setEmailVerified(true);
                admin.setActive(true);
                admin.setCreatedAt(LocalDateTime.now());
                admin.setUpdatedAt(LocalDateTime.now());

                userRepository.save(admin);
                System.out.println("Admin user seeded successfully: " + adminEmail);
            } else {
                System.out.println("Admin user already exists.");
            }
        };
    }
}
