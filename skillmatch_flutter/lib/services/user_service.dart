import '../models/auth_response.dart';
import '../models/user_model.dart';
import 'firebase_auth_service.dart';

class UserService {
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Register method with full user details
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      // Create user with email and password
      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile with additional details
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        name: displayName,
        profilePicture: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // For now, returning a basic AuthResponse
      // In a real implementation, you might want to call your backend API
      final token = await credential.user!.getIdToken() ?? '';
      return AuthResponse(
        idToken: token,
        refreshToken: '',
        uid: credential.user!.uid,
        user: user,
      );
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Login method
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user model from Firebase user data
      final user = UserModel(
        id: credential.user!.uid,
        email: credential.user!.email ?? '',
        name: credential.user!.displayName,
        profilePicture: credential.user!.photoURL,
        createdAt: credential.user!.metadata.creationTime,
        updatedAt: credential.user!.metadata.lastSignInTime,
      );

      // Create and return auth response
      final token = await credential.user!.getIdToken() ?? '';
      return AuthResponse(
        idToken: token,
        refreshToken: '',
        uid: credential.user!.uid,
        user: user,
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Update profile method
  Future<UserModel> updateProfile({
    required String displayName,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      // Update display name and photo URL in Firebase
      await currentUser.updateDisplayName(displayName);
      if (profilePictureUrl != null) {
        await currentUser.updatePhotoURL(profilePictureUrl);
      }

      // Return updated user model
      return UserModel(
        id: currentUser.uid,
        email: currentUser.email ?? '',
        name: displayName,
        profilePicture: profilePictureUrl,
        createdAt: currentUser.metadata.creationTime,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }
}