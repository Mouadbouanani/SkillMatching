import 'package:equatable/equatable.dart';
import '../../../core/models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error, needsProfile }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? token;
  final String? errorMessage;
  final bool isNewRegistration;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
    this.isNewRegistration = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? token,
    String? errorMessage,
    bool? isNewRegistration,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
      isNewRegistration: isNewRegistration ?? this.isNewRegistration,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get isClient => user?.role == UserRole.client;
  bool get isProvider => user?.role == UserRole.provider;

  @override
  List<Object?> get props => [status, user, token, errorMessage, isNewRegistration];
}
