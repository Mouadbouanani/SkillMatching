import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../repository/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

export 'profile_event.dart';
export 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<CreateProfileEvent>(_onCreateProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<AddSkillEvent>(_onAddSkill);
    on<ClearProfileEvent>(_onClearProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    
    try {
      final profile = await _profileRepository.getProfile(event.userId);
      emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
      ));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Erreur lors du chargement du profil',
      ));
    }
  }

  Future<void> _onCreateProfile(
    CreateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    
    try {
      final profile = await _profileRepository.createProfile(
        displayName: event.displayName,
        bio: event.bio,
        location: event.location,
        availability: event.availability,
        profilePictureUrl: event.profilePictureUrl,
      );
      emit(state.copyWith(
        status: ProfileStatus.created,
        profile: profile,
      ));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Erreur lors de la création du profil',
      ));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    
    try {
      final profile = await _profileRepository.updateProfile(
        event.userId,
        event.data,
      );
      emit(state.copyWith(
        status: ProfileStatus.updated,
        profile: profile,
      ));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Erreur lors de la mise à jour du profil',
      ));
    }
  }

  Future<void> _onAddSkill(
    AddSkillEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isAddingSkill: true));
    
    try {
      await _profileRepository.addSkill(event.userId, event.skill);
      
      // Reload profile to get updated skills
      final profile = await _profileRepository.getProfile(event.userId);
      emit(state.copyWith(
        status: ProfileStatus.updated,
        profile: profile,
        isAddingSkill: false,
      ));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: message,
        isAddingSkill: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'Erreur lors de l\'ajout de la compétence',
        isAddingSkill: false,
      ));
    }
  }

  Future<void> _onClearProfile(
    ClearProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileState());
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message'] ?? data['error'] ?? 'Erreur de profil';
      }
      if (data is String) {
        return data;
      }
    }
    
    switch (e.response?.statusCode) {
      case 404:
        return 'Profil non trouvé';
      case 403:
        return 'Accès non autorisé';
      case 500:
        return 'Erreur serveur';
      default:
        return 'Erreur de connexion au serveur';
    }
  }
}
