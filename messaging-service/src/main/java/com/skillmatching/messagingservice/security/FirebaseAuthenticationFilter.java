package com.skillmatching.messagingservice.security;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.firebase.FirebaseApp;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.stereotype.Component;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Component
public class FirebaseAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(FirebaseAuthenticationFilter.class);
    private final FirebaseApp firebaseApp;

    public FirebaseAuthenticationFilter(FirebaseApp firebaseApp) {
        this.firebaseApp = firebaseApp;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        String header = request.getHeader("Authorization");
        logger.info("Processing request: {} {}, Authorization Header present: {}",
                request.getMethod(), request.getRequestURI(), header != null);

        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);

            try {
                FirebaseToken decodedToken = FirebaseAuth.getInstance(firebaseApp).verifyIdToken(token);
                String uid = decodedToken.getUid();

                // Extract role from custom claims
                List<SimpleGrantedAuthority> authorities = new ArrayList<>();
                Object roleClaim = decodedToken.getClaims().get("role");

                if (roleClaim != null) {
                    String role = roleClaim.toString().toUpperCase();
                    authorities.add(new SimpleGrantedAuthority("ROLE_" + role));
                } else {
                    authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
                }

                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        uid,
                        null,
                        authorities);

                SecurityContextHolder.getContext().setAuthentication(authentication);
                logger.info("Successfully authenticated user: {}", uid);

            } catch (Exception e) {
                logger.error("Firebase Auth Error: {}", e.getMessage());
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }
        } else {
            logger.info("No valid Authorization header found");
        }

        filterChain.doFilter(request, response);
    }
}
