import 'package:equatable/equatable.dart';
import '../../../core/models/skill_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  final String userId;

  const LoadProfileEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateProfileEvent extends ProfileEvent {
  final String displayName;
  final String? bio;
  final String? location;
  final String? availability;
  final String? profilePictureUrl;

  const CreateProfileEvent({
    required this.displayName,
    this.bio,
    this.location,
    this.availability,
    this.profilePictureUrl,
  });

  @override
  List<Object?> get props => [displayName, bio, location, availability, profilePictureUrl];
}

class UpdateProfileEvent extends ProfileEvent {
  final String userId;
  final Map<String, dynamic> data;

  const UpdateProfileEvent({
    required this.userId,
    required this.data,
  });

  @override
  List<Object?> get props => [userId, data];
}

class AddSkillEvent extends ProfileEvent {
  final String userId;
  final Skill skill;

  const AddSkillEvent({
    required this.userId,
    required this.skill,
  });

  @override
  List<Object?> get props => [userId, skill];
}

class ClearProfileEvent extends ProfileEvent {}
