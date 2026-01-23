package com.skillmatching.userservice.controller;


import com.google.firebase.auth.FirebaseAuthException;
import com.skillmatching.userservice.dto.ErrorResponse;
import com.skillmatching.userservice.dto.UpdateRoleRequest;
import com.skillmatching.userservice.dto.UserDTO;
import com.skillmatching.userservice.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin")
@CrossOrigin(origins = "*")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    @Autowired
    private UserService userService;


    @GetMapping("/users")
    public ResponseEntity<?>getAllUsers(){
        try{
            List<UserDTO> users = userService.findAllUsers();
            return ResponseEntity.ok(users);
        }catch(Exception e){
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("Erreur lors de recuperation des utilisateurs :"+ e.getMessage()));
        }
    }

    @PutMapping("/users/{firebaseUid}/role")
    public ResponseEntity<?> updateRole(@PathVariable String firebaseUid, @Valid @RequestBody UpdateRoleRequest request){
        try{
            UserDTO updateUser = userService.updateRole(firebaseUid, request.getNewRole());
            return ResponseEntity.ok(updateUser);
        }catch(FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("Erreur Firebase: " + e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }

    @DeleteMapping("/users/{firebaseUid}")
    public ResponseEntity<?> deleteUser(@PathVariable String  firebaseUid){
        try{
            userService.deleteUser(firebaseUid);
            return ResponseEntity.ok().body(new ErrorResponse("Utilisateur supprime avec succes."));
        }catch(FirebaseAuthException e) {
            return   ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("Erreur Firebase :"+e.getMessage()));

        }catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ErrorResponse(e.getMessage()));
        }catch(Exception e ){
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse(e.getMessage()));
        }
    }




}
