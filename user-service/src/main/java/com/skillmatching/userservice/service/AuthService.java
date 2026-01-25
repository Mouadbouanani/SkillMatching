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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Value("${firebase.api-key}")
    private String firebaseApiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    @Autowired
    private FirebaseService firebaseService;

    @Autowired
    private UserRepository userRepository;

    public AuthResponse login(LoginRequest request) {
        String url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + firebaseApiKey;

        java.util.Map<String, Object> body = new java.util.HashMap<>();
        body.put("email", request.getEmail());
        body.put("password", request.getPassword());
        body.put("returnSecureToken", true);

        try {
            org.springframework.http.ResponseEntity<java.util.Map> response = restTemplate.postForEntity(url, body,
                    java.util.Map.class);
            java.util.Map<String, Object> responseBody = response.getBody();

            if (responseBody == null) {
                throw new RuntimeException("Erreur de connexion a Firebase");
            }

            // Check if there's an error in the response
            if (responseBody.containsKey("error")) {
                java.util.Map<String, Object> error = (java.util.Map<String, Object>) responseBody.get("error");
                String errorMessage = (String) error.get("message");
                logger.error("Firebase authentication error: {}", errorMessage);
                throw new RuntimeException("Echec de l'authentification : Email ou mot de passe incorrect");
            }

            String idToken = (String) responseBody.get("idToken");
            String refreshToken = (String) responseBody.get("refreshToken");
            String uid = (String) responseBody.get("localId");

            // Get user from database
            UserDTO userDto = getUserByFirebaseUid(uid);

            return new AuthResponse(idToken, refreshToken, uid, userDto);
        } catch (org.springframework.web.client.HttpClientErrorException e) {
            logger.error("Firebase HTTP Error: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
            throw new RuntimeException("Echec de l'authentification : Email ou mot de passe incorrect");
        } catch (RuntimeException e) {
            if ("User non trouve".equals(e.getMessage())) {
                logger.error("User found in Firebase but not in Database.");
                throw new RuntimeException(
                        "Echec de l'authentification : Compte existant dans Firebase mais introuvable dans la base de donnees locale.");
            }
            throw e;
        } catch (Exception e) {
            logger.error("Login Error: {}", e.getMessage(), e);
            throw new RuntimeException("Echec de l'authentification : Erreur serveur interne (" + e.getMessage() + ")");
        }
    }

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
                    request.getDisplayName() // Use the provided display name
            );

            // Create database user
            User user = new User();
            user.setEmail(request.getEmail());
            user.setFirebaseUid(firebaseUser.getUid());
            user.setDisplayName(request.getDisplayName()); // Set display name
            user.setPhoneNumber(request.getPhoneNumber()); // Set phone number
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
        dto.setDisplayName(user.getDisplayName()); // Include display name
        dto.setPhoneNumber(user.getPhoneNumber()); // Include phone number
        dto.setRole(user.getRole().toString());
        dto.setEmailVerified(user.getEmailVerified());
        dto.setProfilePictureUrl(user.getProfilePictureUrl()); // Include profile picture
        dto.setCreatedAt(user.getCreatedAt());
        dto.setUpdatedAt(user.getUpdatedAt());
        return dto;
    }
}