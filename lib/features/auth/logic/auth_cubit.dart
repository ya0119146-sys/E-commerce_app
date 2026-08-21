import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/user_model.dart';
import '../data/repos/auth_repository.dart';
import '../../../core/network/api_exception.dart';

part 'auth_state.dart';

/// Auth Cubit — manages authentication state.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  /// Check if user is already logged in.
  Future<void> checkAuthStatus() async {
    try {
      final loggedIn = await _repository.isLoggedIn();
      if (loggedIn) {
        final user = await _repository.getProfile();
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  /// Login with email and password.
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final user = await _repository.login(email: email, password: password);
      emit(AuthAuthenticated(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Login failed. Please try again.'));
    }
  }

  /// Signup with name, email, and password.
  Future<void> signup({
    required String name,
    required String userName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _repository.signup(
        name: name,
        userName: userName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      emit(AuthAuthenticated(user));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Signup failed. Please try again.'));
    }
  }

  /// Logout and clear session.
  Future<void> logout() async {
    await _repository.logout();
    emit(AuthUnauthenticated());
  }

  /// Forget password.
  Future<void> forgetPassword(String email) async {
    emit(AuthLoading());
    try {
      final message = await _repository.forgetPassword(email);
      emit(AuthResetCodeSent(message));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Failed to send reset code.'));
    }
  }

  /// Verify reset code.
  Future<void> verifyCode(String code) async {
    emit(AuthLoading());
    try {
      final status = await _repository.verifyCode(code);
      emit(AuthResetCodeVerified(status));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Failed to verify reset code.'));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String confirmPassword,
  }) async {
    emit(AuthLoading());
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        password: password,
        confirmPassword: confirmPassword,
      );
      emit(AuthUnauthenticated());
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Failed to change password.'));
    }
  }
}
