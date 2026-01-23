package com.skillmatching.profileservice.util;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import org.springframework.stereotype.Component;

/**
 * Utilitaire pour générer des custom tokens Firebase pour les tests
 * 
 * ⚠️ ATTENTION: Les custom tokens doivent être échangés contre des ID tokens
 * côté client avec Firebase Auth SDK
 */
@Component
public class TokenGenerator {

    /**
     * Génère un custom token pour un utilisateur
     * Ce token doit ensuite être échangé contre un ID token côté client
     * 
     * @param uid Firebase UID de l'utilisateur
     * @return Custom token (à échanger contre ID token)
     * @throws FirebaseAuthException
     */
    public String generateCustomToken(String uid) throws FirebaseAuthException {
        return FirebaseAuth.getInstance().createCustomToken(uid);
    }
}

