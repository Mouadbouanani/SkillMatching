import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final String role;
  final String? phoneNumber;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.displayName,
    required this.role,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [email, password, displayName, role, phoneNumber];
}

class LogoutEvent extends AuthEvent {}

class GetCurrentUserEvent extends AuthEvent {}
