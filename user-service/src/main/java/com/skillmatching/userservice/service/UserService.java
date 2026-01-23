package com.skillmatching.userservice.service;

import com.google.firebase.auth.FirebaseAuthException;
import com.skillmatching.userservice.dto.UserDTO;
import com.skillmatching.userservice.entity.User;
import com.skillmatching.userservice.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


@Service
public class UserService {
    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private FirebaseService firebaseService;

    @Autowired
    private UserRepository userRepository;




    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

   public void addUser(User user){
        userRepository.save(user);
   }

    /**
     * @Admin Fonctionnalité
     * Récupère la liste de tous les utilisateurs.
     */
    public List<UserDTO> findAllUsers() {
        return userRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * @Admin Fonctionnalité
     * Met à jour le rôle d'un utilisateur et met à jour les Custom Claims dans Firebase.
     */
    @Transactional
    public UserDTO updateRole(String firebaseUid, User.UserRole newRole) throws FirebaseAuthException {
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("User non trouve"));

        // 1. Mise à jour dans la base de données
        user.setRole(newRole);
        user = userRepository.save(user);

        // 2. Mise à jour dans Firebase Custom Claims (ESSENTIEL POUR LA SÉCURITÉ)
        Map<String, Object> claims = new HashMap<>();
        // Utilisez la valeur en minuscule comme c'est la convention standard
        claims.put("role", newRole.name().toLowerCase());

        firebaseService.setCustomClaims(firebaseUid, claims);
        logger.info("Role updated for Firebase user {}. New role: {}", firebaseUid, newRole.name());

        return convertToDTO(user);
    }

    /**
     * @Admin Fonctionnalité
     * Supprime un utilisateur de Firebase et de la base de données.
     */
    @Transactional
    public void deleteUser(String firebaseUid) throws FirebaseAuthException {
        // 1. Suppression dans Firebase
        firebaseService.deleteUser(firebaseUid);

        // 2. Suppression dans la base de données
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("User non trouve"));
        userRepository.delete(user);

        logger.info("User deleted: {}", firebaseUid);
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
