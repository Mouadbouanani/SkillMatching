// lib/models/auth_response.dart
import 'user_model.dart';

class AuthResponse {
  final String idToken;
  final String refreshToken;
  final String uid;
  final UserModel user;
  
  AuthResponse({
    required this.idToken,
    required this.refreshToken,
    required this.uid,
    required this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      idToken: json['idToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      uid: json['uid'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}