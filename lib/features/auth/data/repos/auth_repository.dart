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
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      final user = UserModel.fromJson(response.data['data'] ?? response.data);
      // if (user.token != null) {
      //   await _client.saveToken(user.token!);
      // }
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
        final token = response.data['token'];
        print("token : $token");
        //final user = UserModel.fromJson(data).copyWith(token: token as String?);
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
  Future<String> changePassword({
    required String currentPassword,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.dio.patch(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      return response.data['message'] ?? 'Password changed successfully!';
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

  // /// Update user profile.
  // Future<UserModel> updateProfile({String? name, String? imagePath}) async {
  //   try {
  //     final formData = FormData();
  //     if (name != null) formData.fields.add(MapEntry('name', name));

  //     if (imagePath != null) {
  //       formData.files.add(
  //         MapEntry(
  //           'image',
  //           await MultipartFile.fromFile(imagePath),
  //         ),
  //       );
  //     }

  //     final response = await _client.dio.patch(
  //       ApiConstants.profileUpdate,
  //       data: formData,
  //     );

  //     final data = response.data['data'] ?? response.data;
  //     return UserModel.fromJson(data);
  //   } on DioException catch (e) {
  //     throw e.error as ApiException? ??
  //         const ApiException(message: 'Failed to update profile');
  //   }
  // }

  /// Delete profile.
  Future<void> deleteProfile() async {
    try {
      await _client.dio.delete(ApiConstants.profile);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete profile');
    }
  }

  /// Logout — clear stored token.
  Future<void> logout() async {
    await _client.clearToken();
  }

  /// Forget password — send reset code to email.
  Future<String> forgetPassword(String email) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.forgetPassword,
        data: {'email': email},
      );
      return response.data['message'] ?? 'Reset code sent to your email';
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to send reset code');
    }
  }

  /// Verify reset code.
  Future<String> verifyCode(String code) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.verifyCode,
        data: {'resetCode': code},
      );
      return response.data['status'] ?? 'Success';
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Invalid reset code');
    }
  }

  /// Check if user is logged in.
  Future<bool> isLoggedIn() async {
    return await _client.hasToken();
  }
}
