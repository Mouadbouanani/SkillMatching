import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/auth_interceptor.dart';
import '../../../core/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  AuthRepository(this._apiClient, this._prefs);

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? phoneNumber,
  }) async {
    final response = await _apiClient.register(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
      phoneNumber: phoneNumber,
    );

    final authResponse = AuthResponse.fromJson(response.data);
    
    // Save auth data locally
    await AuthInterceptor.saveAuthData(
      _prefs,
      token: authResponse.idToken,
      refreshToken: authResponse.refreshToken,
      userId: authResponse.uid,
      role: authResponse.user.role.name.toUpperCase(),
    );

    return authResponse;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.login(
      email: email,
      password: password,
    );

    final authResponse = AuthResponse.fromJson(response.data);
    
    // Save auth data locally
    await AuthInterceptor.saveAuthData(
      _prefs,
      token: authResponse.idToken,
      refreshToken: authResponse.refreshToken,
      userId: authResponse.uid,
      role: authResponse.user.role.name.toUpperCase(),
    );

    return authResponse;
  }

  Future<User> getCurrentUser() async {
    final response = await _apiClient.getCurrentUser();
    return User.fromJson(response.data);
  }

  Future<void> logout() async {
    await AuthInterceptor.clearAuthData(_prefs);
  }

  bool isLoggedIn() {
    return AuthInterceptor.isLoggedIn(_prefs);
  }

  String? getCurrentUserId() {
    return AuthInterceptor.getUserId(_prefs);
  }

  String? getCurrentUserRole() {
    return AuthInterceptor.getUserRole(_prefs);
  }

  UserRole? get currentRole {
    final role = getCurrentUserRole();
    if (role == null) return null;
    
    switch (role.toUpperCase()) {
      case 'CLIENT':
        return UserRole.client;
      case 'PROVIDER':
        return UserRole.provider;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return null;
    }
  }
}
