import 'package:dio/dio.dart';
import 'package:e_commerce/features/auth/data/models/user_model.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

/// Repository for profile operations.
class ProfileRepository {
  final DioClient _client;

  ProfileRepository(this._client);

  /// Get current user profile.
  Future<UserModel> getProfile() async {
    try {
      final response = await _client.dio.get(ApiConstants.profile);
      print("response.data['data']$response.data['data']");
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load profile');
    }
  }

  /// Update user profile.
  Future<UserModel> updateProfile({String? name, String? imagePath}) async {
    try {
      final formData = FormData();
      if (name != null) formData.fields.add(MapEntry('name', name));

      if (imagePath != null) {
        formData.files.add(
          MapEntry('image', await MultipartFile.fromFile(imagePath)),
        );
      }

      final response = await _client.dio.put(
        ApiConstants.profileUpdate,
        data: formData,
      );

      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update profile');
    }
  }

  /// Delete profile.
  Future<void> deleteProfile() async {
    try {
      await _client.dio.delete(ApiConstants.profile);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete profile');
    }
  }
}
