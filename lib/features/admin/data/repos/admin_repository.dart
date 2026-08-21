import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../store/data/models/category_model.dart';
import '../../../store/data/models/product_model.dart';
import '../../../store/data/models/sub_category_model.dart';
import '../../../auth/data/models/user_model.dart';

/// Repository for Admin-related management operations (CRUD).
class AdminRepository {
  final DioClient _client;

  AdminRepository(this._client);

  // ─── Category Management ───

  Future<CategoryModel> createCategory(FormData data) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.categories,
        data: data,
      );
      return CategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to create category');
    }
  }

  Future<CategoryModel> updateCategory(String id, FormData data) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.categoryById(id),
        data: data,
      );
      return CategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update category');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _client.dio.delete(ApiConstants.categoryById(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete category');
    }
  }

  // ─── Subcategory Management ───

  Future<SubCategoryModel> createSubcategory(dynamic data) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.getAllSubcategories,
        data: data,
      );
      return SubCategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to create subcategory');
    }
  }

  Future<SubCategoryModel> updateSubcategory(
    String id,
    dynamic data,
  ) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.updateSubCategory(id),
        data: data,
      );
      return SubCategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update subcategory');
    }
  }

  Future<void> deleteSubcategory(String id) async {
    try {
      await _client.dio.delete(ApiConstants.deleteSubCategory(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete subcategory');
    }
  }

  // ─── Product Management ───

  Future<ProductModel> createProduct(FormData data) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.products,
        data: data,
      );
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to create product');
    }
  }

  Future<ProductModel> updateProduct(String id, FormData data) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.productById(id),
        data: data,
      );
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update product');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _client.dio.delete(ApiConstants.productById(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete product');
    }
  }

  Future<List<SubCategoryModel>> getAllSubcategories() async {
    try {
      final response = await _client.dio.get(ApiConstants.getAllSubcategories);
      final data = response.data['data'] as List? ?? [];
      return data.map((e) => SubCategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to fetch subcategories');
    }
  }

  // ─── User Management ───

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _client.dio.get(ApiConstants.users);
      final data = response.data['data'] as List? ?? [];
      return data.map((e) => UserModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to fetch users');
    }
  }

  Future<UserModel> getUserDetails(String id) async {
    try {
      final response = await _client.dio.get(ApiConstants.userById(id));
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to fetch user details');
    }
  }

  Future<UserModel> createUser(FormData data) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.users,
        data: data,
      );
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to create user');
    }
  }

  Future<UserModel> updateUser(String id, FormData data) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.userById(id),
        data: data,
      );
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update user');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _client.dio.delete(ApiConstants.userById(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete user');
    }
  }
}
