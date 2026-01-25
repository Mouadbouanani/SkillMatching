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
                                .sessionManagement(session -> session.sessionCreationPolicy(
                                                org.springframework.security.config.http.SessionCreationPolicy.STATELESS))
                                .authorizeHttpRequests(auth -> auth
                                                .requestMatchers("/health", "/api/jobs/health").permitAll()
                                                .requestMatchers("/categories", "/api/jobs/categories").permitAll()
                                                .requestMatchers("/open", "/api/jobs/open").permitAll()
                                                .requestMatchers("/hello", "/api/jobs/hello").permitAll()
                                                .requestMatchers(HttpMethod.GET, "/", "/api/jobs/").permitAll()
                                                .requestMatchers(HttpMethod.GET, "/{jobId}", "/api/jobs/{jobId}")
                                                .permitAll()
                                                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**",
                                                                "/swagger-ui.html")
                                                .permitAll()
                                                .requestMatchers(HttpMethod.POST, "/create", "/api/jobs/create")
                                                .authenticated()
                                                .requestMatchers(HttpMethod.POST, "/apply", "/api/jobs/apply")
                                                .authenticated()
                                                .requestMatchers(HttpMethod.PUT, "/**").authenticated()
                                                .requestMatchers(HttpMethod.DELETE, "/**").authenticated()
                                                .anyRequest().authenticated())
                                .addFilterBefore(
                                                firebaseAuthenticationFilter,
                                                UsernamePasswordAuthenticationFilter.class);

                return http.build();
        }
}