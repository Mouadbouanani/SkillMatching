class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? profilePicture;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? role; // Added role field

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.profilePicture,
    this.createdAt,
    this.updatedAt,
    this.role,
  });

  // Getter to match what the home screen expects
  String? get displayName => name;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      profilePicture: json['profilePicture'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'role': role,
    };
  }
}