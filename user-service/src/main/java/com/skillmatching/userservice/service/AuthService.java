package com.skillmatching.userservice.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.skillmatching.userservice.dto.*;
import com.skillmatching.userservice.entity.User;
import com.skillmatching.userservice.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private FirebaseService firebaseService;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public AuthResponse register(UserRegistrationDTO request) throws FirebaseAuthException {
        // Check if email exists in database first
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email deja utilise");
        }

        UserRecord firebaseUser = null;
        try {
            // Create Firebase user
            firebaseUser = firebaseService.createUser(
                    request.getEmail(),
                    request.getPassword(),
                    request.getEmail() // Use email as display name initially
            );

            // Create database user
            User user = new User();
            user.setEmail(request.getEmail());
            user.setFirebaseUid(firebaseUser.getUid());
            String roleStr = request.getRole() != null ? request.getRole() : "CLIENT";
            user.setRole(User.UserRole.valueOf(roleStr));
            user.setEmailVerified(false);

            user = userRepository.save(user);

            // Set Custom Claims in Firebase (essential for security in other services)
            java.util.Map<String, Object> claims = new java.util.HashMap<>();
            claims.put("role", roleStr.toLowerCase());
            firebaseService.setCustomClaims(user.getFirebaseUid(), claims);

            logger.info("User registered and role set in Firebase: {}", user.getEmail());

            return new AuthResponse(
                    "", // idToken usually comes from frontend client
                    "",
                    firebaseUser.getUid(),
                    convertToDTO(user));
        } catch (Exception e) {
            // Clean up Firebase user if database insertion fails
            if (firebaseUser != null) {
                try {
                    FirebaseAuth.getInstance().deleteUser(firebaseUser.getUid());
                    logger.info("Cleaned up Firebase user after registration failure: {}", firebaseUser.getUid());
                } catch (FirebaseAuthException cleanupException) {
                    logger.error("Failed to cleanup Firebase user after registration failure: ", cleanupException);
                }
            }
            throw e; // Re-throw the original exception
        }
    }

    public UserDTO getUserByFirebaseUid(String firebaseUid) {
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("User non trouve"));

        return convertToDTO(user);
    }

    private UserDTO convertToDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setFirebaseUid(user.getFirebaseUid());
        dto.setRole(user.getRole().toString());
        dto.setEmailVerified(user.getEmailVerified());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setUpdatedAt(user.getUpdatedAt());
        return dto;
    }
}