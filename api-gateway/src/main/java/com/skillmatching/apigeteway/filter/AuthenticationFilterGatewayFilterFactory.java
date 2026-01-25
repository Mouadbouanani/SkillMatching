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
public class AuthenticationFilterGatewayFilterFactory
        extends AbstractGatewayFilterFactory<AuthenticationFilterGatewayFilterFactory.Config> {

    private static final Logger logger = LoggerFactory.getLogger(AuthenticationFilterGatewayFilterFactory.class);
    private final com.google.firebase.FirebaseApp firebaseApp;

    public AuthenticationFilterGatewayFilterFactory(com.google.firebase.FirebaseApp firebaseApp) {
        super(Config.class);
        this.firebaseApp = firebaseApp;
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            try {
                String token = getTokenFromRequest(exchange.getRequest());

                if (token == null || token.isEmpty()) {
                    logger.warn("No token provided for path: {}", exchange.getRequest().getPath());
                    exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                    return exchange.getResponse().setComplete();
                }

                // Verify token with Firebase using the injected app
                var decodedToken = FirebaseAuth.getInstance(firebaseApp).verifyIdToken(token);
                String uid = decodedToken.getUid();

                // Add user info to header for downstream services
                String role = (String) decodedToken.getClaims().get("role");

                logger.info("Token verified for user: {}", uid);

                // IMPORTANT: Continue with the mutated exchange!
                org.springframework.http.server.reactive.ServerHttpRequest mutatedRequest = exchange.getRequest()
                        .mutate()
                        .header("X-User-Id", uid)
                        .header("X-User-Email", decodedToken.getEmail() != null ? decodedToken.getEmail() : "")
                        .header("X-User-Role", role != null ? role : "user")
                        .build();

                return chain.filter(exchange.mutate().request(mutatedRequest).build());

            } catch (FirebaseAuthException e) {
                logger.error("Token verification failed: {}", e.getMessage());
                exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                return exchange.getResponse().setComplete();
            } catch (Exception e) {
                logger.error("Authentication error: {}", e.getMessage());
                exchange.getResponse().setStatusCode(HttpStatus.INTERNAL_SERVER_ERROR);
                return exchange.getResponse().setComplete();
            }
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