package com.skillmatching.apigeteway.filter;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component
public class AuthenticationFilter extends AbstractGatewayFilterFactory<AuthenticationFilter.Config> {

    private static final Logger logger = LoggerFactory.getLogger(AuthenticationFilter.class);

    public AuthenticationFilter() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            try {
                String token = getTokenFromRequest(exchange.getRequest());

                if (token == null || token.isEmpty()) {
                    logger.warn("No token provided");
                    exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                    return exchange.getResponse().setComplete();
                }

                // Verify token with Firebase
                var decodedToken = FirebaseAuth.getInstance().verifyIdToken(token);
                String uid = decodedToken.getUid();

                // Add user info to header for downstream services
                String role = (String) decodedToken.getClaims().get("role");

                exchange.getRequest().mutate()
                        .header("X-User-Id", uid)
                        .header("X-User-Email", decodedToken.getEmail() != null ? decodedToken.getEmail() : "")
                        .header("X-User-Role", role != null ? role : "user")
                        .build();

                logger.info("Token verified for user: {}", uid);

            } catch (FirebaseAuthException e) {
                logger.error("Token verification failed: {}", e.getMessage());
                exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                return exchange.getResponse().setComplete();
            } catch (Exception e) {
                logger.error("Authentication error: {}", e.getMessage());
                exchange.getResponse().setStatusCode(HttpStatus.INTERNAL_SERVER_ERROR);
                return exchange.getResponse().setComplete();
            }

            return chain.filter(exchange);
        };
    }

    private String getTokenFromRequest(org.springframework.http.server.reactive.ServerHttpRequest request) {
        String authHeader = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }

        return null;
    }

    public static class Config {
    }
}