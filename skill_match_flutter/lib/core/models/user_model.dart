import 'package:equatable/equatable.dart';

enum UserRole { client, provider, admin }

class User extends Equatable {
  final String id;
  final String? firebaseUid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? phoneNumber;
  final DateTime? createdAt;

  const User({
    required this.id,
    this.firebaseUid,
    required this.email,
    required this.displayName,
    required this.role,
    this.phoneNumber,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['uid'] ?? '',
      firebaseUid: json['firebaseUid'],
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: _parseRole(json['role']),
      phoneNumber: json['phoneNumber'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'displayName': displayName,
      'role': role.name.toUpperCase(),
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role?.toUpperCase()) {
      case 'CLIENT':
      case 'ROLE_CLIENT':
        return UserRole.client;
      case 'PROVIDER':
      case 'ROLE_PROVIDER':
        return UserRole.provider;
      case 'ADMIN':
      case 'ROLE_ADMIN':
        return UserRole.admin;
      default:
        return UserRole.client;
    }
  }

  bool get isClient => role == UserRole.client;
  bool get isProvider => role == UserRole.provider;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [id, firebaseUid, email, displayName, role, phoneNumber, createdAt];
}

class AuthResponse extends Equatable {
  final String idToken;
  final String? refreshToken;
  final String uid;
  final User user;

  const AuthResponse({
    required this.idToken,
    this.refreshToken,
    required this.uid,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      idToken: json['idToken'] ?? '',
      refreshToken: json['refreshToken'],
      uid: json['uid'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [idToken, refreshToken, uid, user];
}
