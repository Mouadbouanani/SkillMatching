package com.skillmatching.userservice.service;

import com.skillmatching.userservice.dto.*;
import com.skillmatching.userservice.entity.User;
import com.skillmatching.userservice.repository.UserRepository;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private FirebaseService firebaseService;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public AuthResponse register(UserRegistrationDTO request) throws FirebaseAuthException {

        // Verifier si email existe
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email deja utilise");
        }

        // Creer user Firebase
        UserRecord firebaseUser = firebaseService.createUser(
                request.getEmail(),
                request.getPassword(),
                request.getDisplayName()
        );

        // Creer user en base de donnees
        User user = new User();
        user.setEmail(request.getEmail());
        user.setFirebaseUid(firebaseUser.getUid());
        user.setDisplayName(request.getDisplayName());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setRole(User.UserRole.valueOf(request.getRole() != null ? request.getRole() : "CLIENT"));
        user.setEmailVerified(false);

        user = userRepository.save(user);

        logger.info("User registered: {}", user.getEmail());

        return new AuthResponse(
                firebaseUser.getCustomClaims() != null ? firebaseUser.getCustomClaims().toString() : "",
                "",
                firebaseUser.getUid(),
                convertToDTO(user)
        );
    }

    public UserDTO getUserByFirebaseUid(String firebaseUid) {
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("User non trouve"));

        return convertToDTO(user);
    }

    public UserDTO updateUser(String firebaseUid, User userUpdate) {
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("User non trouve"));

        if (userUpdate.getDisplayName() != null) {
            user.setDisplayName(userUpdate.getDisplayName());
        }
        if (userUpdate.getPhoneNumber() != null) {
            user.setPhoneNumber(userUpdate.getPhoneNumber());
        }
        if (userUpdate.getProfilePictureUrl() != null) {
            user.setProfilePictureUrl(userUpdate.getProfilePictureUrl());
        }

        user = userRepository.save(user);
        return convertToDTO(user);
    }

    private UserDTO convertToDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setFirebaseUid(user.getFirebaseUid());
        dto.setDisplayName(user.getDisplayName());
        dto.setPhoneNumber(user.getPhoneNumber());
        dto.setRole(user.getRole().toString());
        dto.setEmailVerified(user.getEmailVerified());
        dto.setProfilePictureUrl(user.getProfilePictureUrl());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setUpdatedAt(user.getUpdatedAt());
        return dto;
    }
}