package com.skillmatching.profileservice.controller;

import com.google.firebase.auth.FirebaseAuthException;
import com.skillmatching.profileservice.util.TokenGenerator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Controller de test pour générer des tokens
 * ⚠️ À utiliser uniquement en développement
 */
@RestController
@RequestMapping("/test")
public class TestController {

    @Autowired
    private TokenGenerator tokenGenerator;

    /**
     * Génère un custom token pour un utilisateur
     * 
     * ⚠️ Ce endpoint devrait être désactivé en production
     * Le custom token doit être échangé contre un ID token côté client
     */
    @PostMapping("/custom-token/{uid}")
    public ResponseEntity<?> generateCustomToken(@PathVariable String uid) {
        try {
            String customToken = tokenGenerator.generateCustomToken(uid);
            
            Map<String, String> response = new HashMap<>();
            response.put("customToken", customToken);
            response.put("uid", uid);
            response.put("note", "Ce custom token doit être échangé contre un ID token côté client avec Firebase Auth SDK");
            response.put("example", "const idToken = await signInWithCustomToken(auth, customToken).then(u => u.user.getIdToken())");
            
            return ResponseEntity.ok(response);
        } catch (FirebaseAuthException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to generate token");
            error.put("message", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }
}

