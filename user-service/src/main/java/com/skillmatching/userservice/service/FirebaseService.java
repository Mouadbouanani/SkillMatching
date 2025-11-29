package com.skillmatching.userservice.service;


import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.google.firebase.auth.UserRecord.CreateRequest; // <-- CORRECTED IMPORT
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;

@Service
public class FirebaseService {

    private static final Logger logger = LoggerFactory.getLogger(FirebaseService.class);

    public UserRecord createUser(String email, String password, String displayName)
            throws FirebaseAuthException {

        // Use UserRecord.CreateRequest (aliased to CreateRequest in the import)
        CreateRequest request = new CreateRequest()
                .setEmail(email)
                .setPassword(password)
                .setDisplayName(displayName)
                .setEmailVerified(false)
                .setDisabled(false);

        UserRecord userRecord = FirebaseAuth.getInstance().createUser(request);
        logger.info("Firebase user created: {}", userRecord.getUid());
        return userRecord;
    }

    public UserRecord getUserById(String uid) throws FirebaseAuthException {
        return FirebaseAuth.getInstance().getUser(uid);
    }

    public UserRecord getUserByEmail(String email) throws FirebaseAuthException {
        return FirebaseAuth.getInstance().getUserByEmail(email);
    }

    public void deleteUser(String uid) throws FirebaseAuthException {
        FirebaseAuth.getInstance().deleteUser(uid);
        logger.info("Firebase user deleted: {}", uid);
    }

    public void updateUserPassword(String uid, String newPassword) throws FirebaseAuthException {
        FirebaseAuth.getInstance().updateUser(
                new UserRecord.UpdateRequest(uid)
                        .setPassword(newPassword)
        );
    }

    public void setCustomClaims(String uid, Map<String, Object> claims) throws FirebaseAuthException {
        FirebaseAuth.getInstance().setCustomUserClaims(uid, claims);
        logger.info("Custom claims set for user: {}", uid);
    }
}