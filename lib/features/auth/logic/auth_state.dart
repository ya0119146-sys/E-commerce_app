part of 'auth_cubit.dart';

/// Auth states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user.email, user.name];
}

class AuthUnauthenticated extends AuthState {}

/// Emitted after a successful signup when no token is returned.
/// UI should navigate to the login screen.
class AuthSignupSuccess extends AuthState {}

class AuthResetCodeSent extends AuthState {
  final String message;
  const AuthResetCodeSent(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthResetCodeVerified extends AuthState {
  final String status;
  const AuthResetCodeVerified(this.status);

  @override
  List<Object?> get props => [status];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
