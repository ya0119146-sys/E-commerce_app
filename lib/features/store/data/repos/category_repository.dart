import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/category_model.dart';

/// Repository for category-related API calls.
class CategoryRepository {
  final DioClient _client;

  CategoryRepository(this._client);

  /// Fetch all categories.
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.dio.get(ApiConstants.categories);
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load categories');
    }
  }

  /// Fetch subcategories for a parent category.
  Future<List<CategoryModel>> getSubcategories(String categoryId) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.subcategories(categoryId),
      );
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load subcategories');
    }
  }

  /// Create a new category.
  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.categories,
        data: data,
      );
      return CategoryModel.fromJson(
        response.data['data'] as Map<String, dynamic>? ?? response.data,
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to create category');
    }
  }

  /// Update an existing category.
  Future<CategoryModel> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.categoryById(id),
        data: data,
      );
      return CategoryModel.fromJson(
        response.data['data'] as Map<String, dynamic>? ?? response.data,
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update category');
    }
  }

  /// Delete a category.
  Future<void> deleteCategory(String id) async {
    try {
      await _client.dio.delete(ApiConstants.categoryById(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete category');
    }
  }

  /// Create a new subcategory.
  Future<CategoryModel> createSubcategory(Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.getAllSubcategories,
        data: data,
      );
      return CategoryModel.fromJson(
        response.data['data'] as Map<String, dynamic>? ?? response.data,
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to create subcategory');
    }
  }

  /// Update an existing subcategory.
  Future<CategoryModel> updateSubcategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.updateSubCategory(id),
        data: data,
      );
      return CategoryModel.fromJson(
        response.data['data'] as Map<String, dynamic>? ?? response.data,
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update subcategory');
    }
  }

  /// Delete a subcategory.
  Future<void> deleteSubcategory(String id) async {
    try {
      await _client.dio.delete(ApiConstants.deleteSubCategory(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete subcategory');
    }
  }
}
