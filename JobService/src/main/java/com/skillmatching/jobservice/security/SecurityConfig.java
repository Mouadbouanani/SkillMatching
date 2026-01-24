package com.skillmatching.jobservice.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

        private final FirebaseAuthenticationFilter firebaseAuthenticationFilter;

        public SecurityConfig(FirebaseAuthenticationFilter firebaseAuthenticationFilter) {
                this.firebaseAuthenticationFilter = firebaseAuthenticationFilter;
        }

        @Bean
        public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
                http
                                .csrf(csrf -> csrf.disable())
                                .authorizeHttpRequests(auth -> auth
                                                .requestMatchers(HttpMethod.GET, "/{jobId}").permitAll()
                                                .requestMatchers(HttpMethod.GET, "/").permitAll()
                                                .requestMatchers(HttpMethod.GET, "/open").permitAll()
                                                .requestMatchers(HttpMethod.GET, "/categories").permitAll()
                                                .requestMatchers("/hello").permitAll()
                                                .requestMatchers("/api/jobs/health").permitAll()
                                                .anyRequest().authenticated())
                                .addFilterBefore(
                                                firebaseAuthenticationFilter,
                                                UsernamePasswordAuthenticationFilter.class);

                return http.build();
        }
}