import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<GetCurrentUserEvent>(_onGetCurrentUser);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      if (_authRepository.isLoggedIn()) {
        final user = await _authRepository.getCurrentUser();
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } on DioException catch (e) {
      // If we get a 401, the token is expired
      if (e.response?.statusCode == 401) {
        await _authRepository.logout();
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      final authResponse = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        token: authResponse.idToken,
      ));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Une erreur inattendue s\'est produite',
      ));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      // 1. Register
      await _authRepository.register(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        role: event.role,
        phoneNumber: event.phoneNumber,
      );
      
      // 2. Auto Login to get the valid token
      final authResponse = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      
      emit(state.copyWith(
        status: AuthStatus.needsProfile,
        user: authResponse.user,
        token: authResponse.idToken,
        isNewRegistration: true,
      ));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Une erreur inattendue s\'est produite',
      ));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onGetCurrentUser(
    GetCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authRepository.getCurrentUser();
      emit(state.copyWith(user: user));
    } catch (e) {
      // Silently fail - user data is optional refresh
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message'] ?? data['error'] ?? 'Erreur de connexion';
      }
      if (data is String) {
        return data;
      }
    }
    
    switch (e.response?.statusCode) {
      case 400:
        return 'Données invalides';
      case 401:
        return 'Email ou mot de passe incorrect';
      case 403:
        return 'Accès non autorisé';
      case 404:
        return 'Service non disponible';
      case 500:
        return 'Erreur serveur';
      default:
        return 'Erreur de connexion au serveur';
    }
  }
}
