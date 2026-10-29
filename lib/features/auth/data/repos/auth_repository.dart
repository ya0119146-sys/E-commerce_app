import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

/// Repository for authentication and profile operations.
class AuthRepository {
  final DioClient _client;

  AuthRepository(this._client);

  /// Register a new user.
  Future<UserModel> signup({
    required String name,
    required String userName,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.signup,
        data: {
          'name': name,
          'username': userName,
          'phone': phone,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      // Signup returns { data: <user>, message: "..." } — no token.
      final user = UserModel.fromJson(response.data['data'] ?? response.data);
      return user;
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Signup failed');
    }
  }

  /// Login an existing user.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        // Backend returns { data: <user>, token: "<JWT>" } — lowercase 'token'.
        final token = response.data['token'] as String?;
        if (token != null) {
          await _client.saveToken(token);
        }
        return UserModel.fromJson(data);
      } else {
        throw ApiException(message: response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Login failed');
    }
  }

  /// Change password.
  /// Backend field: 'currantPassword' (typo in backend — not 'currentPassword').
  /// HTTP method: PUT (not PATCH).
  /// Returns a new token that must be saved.
  Future<String> changePassword({
    required String currentPassword,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.changePassword,
        data: {
          'currantPassword': currentPassword, // ⚠️ backend typo: 'currantPassword'
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      // Backend returns { data: <user>, token: "<new JWT>" }.
      // Save the new token so subsequent requests continue to work.
      final newToken = response.data['token'] as String?;
      if (newToken != null) {
        await _client.saveToken(newToken);
      }
      return response.data['message'] as String? ?? 'Password changed successfully!';
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to change password');
    }
  }

  /// Get current user profile.
  Future<UserModel> getProfile() async {
    try {
      final response = await _client.dio.get(ApiConstants.profile);
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load profile');
    }
  }

  /// Delete profile.
  /// Endpoint: DELETE /api/v1/profile/delete
  Future<void> deleteProfile() async {
    try {
      await _client.dio.delete(ApiConstants.profileDelete);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete profile');
    }
  }

  /// Logout — clear stored token.
  Future<void> logout() async {
    await _client.clearToken();
    await _client.clearResetToken();
  }

  /// Forget password — send reset code to email.
  /// Backend returns `{ message: "...", Token: "RESET_JWT" }` — capital T.
  /// The reset token must be stored and sent in verifyCode + resetPassword.
  Future<String> forgetPassword(String email) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.forgetPassword,
        data: {'email': email},
      );
      // ⚠️ Backend uses capital 'Token' (not 'token').
      final resetToken = response.data['Token'] as String?;
      if (resetToken != null) {
        await _client.saveResetToken(resetToken);
      }
      return response.data['message'] as String? ?? 'Reset code sent to your email';
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to send reset code');
    }
  }

  /// Verify reset code.
  /// Requires the reset token from forgetPassword as Authorization header.
  /// Body field: 'resetcode' (lowercase, one word — backend exact spelling).
  Future<String> verifyCode(String code) async {
    try {
      final resetToken = await _client.getResetToken();
      if (resetToken == null || resetToken.isEmpty) {
        throw const ApiException(
          message: 'Reset session expired. Please request a new reset code.',
        );
      }
      final response = await _client.dio.post(
        ApiConstants.verifyCode,
        data: {'resetcode': code}, // ⚠️ exact key: 'resetcode' (all lowercase)
        options: Options(
          headers: {'Authorization': 'Bearer $resetToken'},
        ),
      );
      return response.data['message'] as String? ?? 'Code verified';
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Invalid reset code');
    }
  }

  /// Reset password using the stored reset token.
  Future<void> resetPassword({
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final resetToken = await _client.getResetToken();
      if (resetToken == null || resetToken.isEmpty) {
        throw const ApiException(
          message: 'Reset session expired. Please request a new reset code.',
        );
      }
      await _client.dio.post(
        ApiConstants.resetPassword,
        data: {'password': password, 'confirmPassword': confirmPassword},
        options: Options(
          headers: {'Authorization': 'Bearer $resetToken'},
        ),
      );
      // Clear the one-time reset token after use.
      await _client.clearResetToken();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to reset password');
    }
  }

  /// Check if user is logged in.
  Future<bool> isLoggedIn() async {
    return await _client.hasToken();
  }
}
