package com.skillmatching.apigeteway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.web.server.SecurityWebFilterChain;

@Configuration
@EnableWebFluxSecurity
public class SecurityConfig {

    @Bean
    public SecurityWebFilterChain springSecurityFilterChain(ServerHttpSecurity http) {
        return http
                .csrf(ServerHttpSecurity.CsrfSpec::disable)
                // Enable CORS with default configuration - this ensures CORS is handled
                // before other security filters in the Spring Security filter chain
                .cors(cors -> cors.and())
                .authorizeExchange(exchanges -> exchanges
                        .anyExchange().permitAll())
                .build();
    }
}
