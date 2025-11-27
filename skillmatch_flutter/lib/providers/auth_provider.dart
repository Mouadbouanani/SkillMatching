import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';
import '../services/user_service.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  
  AuthResponse? _authResponse;
  bool _isLoading = false;
  String? _errorMessage;
  
  AuthResponse? get authResponse => _authResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authResponse != null;
  UserModel? get currentUser => _authResponse?.user;
  
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String phoneNumber,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _authResponse = await _userService.register(
        email: email,
        password: password,
        displayName: displayName,
        phoneNumber: phoneNumber,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _authResponse = await _userService.login(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _firebaseAuthService.signOut();
    _authResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<bool> updateProfile({
    required String displayName,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final updatedUser = await _userService.updateProfile(
        displayName: displayName,
        phoneNumber: phoneNumber,
        profilePictureUrl: profilePictureUrl,
      );
      
      if (_authResponse != null) {
        _authResponse = AuthResponse(
          idToken: _authResponse!.idToken,
          refreshToken: _authResponse!.refreshToken,
          uid: _authResponse!.uid,
          user: updatedUser,
        );
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Method to check if user is authenticated on app startup
  Future<void> checkAuthStatus() async {
    final user = _firebaseAuthService.getCurrentUser();
    if (user != null) {
      // User is already logged in, create a basic AuthResponse
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName,
        profilePicture: user.photoURL,
        createdAt: user.metadata.creationTime,
        updatedAt: user.metadata.lastSignInTime,
      );

      final token = await user.getIdToken() ?? '';
      _authResponse = AuthResponse(
        idToken: token,
        refreshToken: '',
        uid: user.uid,
        user: userModel,
      );
      notifyListeners();
    }
  }
}