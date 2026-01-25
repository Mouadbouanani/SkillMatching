import 'package:equatable/equatable.dart';
import 'skill_model.dart';

class Profile extends Equatable {
  final String? id;
  final String userId;
  final String displayName;
  final String? bio;
  final double rating;
  final int ratingCount;
  final String? location;
  final String? availability;
  final String? profilePictureUrl;
  final List<Skill> skills;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Profile({
    this.id,
    required this.userId,
    required this.displayName,
    this.bio,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.location,
    this.availability,
    this.profilePictureUrl,
    this.skills = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'] ?? '',
      displayName: json['displayName'] ?? json['display_name'] ?? '',
      bio: json['bio'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? json['rating_count'] ?? 0,
      location: json['location'],
      availability: json['availability'],
      profilePictureUrl: json['profilePictureUrl'] ?? json['profile_picture_url'],
      skills: (json['skills'] as List<dynamic>?)
          ?.map((s) => Skill.fromJson(s))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'displayName': displayName,
      if (bio != null) 'bio': bio,
      'rating': rating,
      'ratingCount': ratingCount,
      if (location != null) 'location': location,
      if (availability != null) 'availability': availability,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      'skills': skills.map((s) => s.toJson()).toList(),
    };
  }

  Profile copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? bio,
    double? rating,
    int? ratingCount,
    String? location,
    String? availability,
    String? profilePictureUrl,
    List<Skill>? skills,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      skills: skills ?? this.skills,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, displayName, bio, rating, ratingCount, 
    location, availability, profilePictureUrl, skills, createdAt, updatedAt
  ];
}
