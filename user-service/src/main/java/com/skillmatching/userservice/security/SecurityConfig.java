package com.skillmatching.userservice.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable()) // Disable CSRF for API endpoints
                .authorizeHttpRequests(auth -> auth
                        // Allow POST requests to /api/users/auth/register without authentication
                        .requestMatchers("/api/users/auth/register").permitAll()
                        // Require authentication for all other requests
                        .anyRequest().authenticated()
                );
        return http.build();
    }
}