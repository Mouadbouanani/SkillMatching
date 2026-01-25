import 'package:equatable/equatable.dart';
import '../../../core/models/profile_model.dart';

enum ProfileStatus { initial, loading, loaded, created, updated, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final Profile? profile;
  final String? errorMessage;
  final bool isAddingSkill;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.isAddingSkill = false,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? profile,
    String? errorMessage,
    bool? isAddingSkill,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      isAddingSkill: isAddingSkill ?? this.isAddingSkill,
    );
  }

  bool get isLoading => status == ProfileStatus.loading;
  bool get hasProfile => profile != null;

  @override
  List<Object?> get props => [status, profile, errorMessage, isAddingSkill];
}
