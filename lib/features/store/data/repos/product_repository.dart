import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';

/// Repository for product-related API calls.
class ProductRepository {
  final DioClient _client;

  ProductRepository(this._client);

  /// Fetch products with optional filters.
  Future<List<ProductModel>> getProducts({
    String? keyword,
    String? category,
    String? subcategory,
    String? sort,
    int page = 1,
    int limit = 8,
  }) async {
    try {
      final search = keyword?.trim();
      final cat = category?.trim();
      final sub = subcategory?.trim();
      final s = sort?.trim();

      final response = await _client.dio.get(
        ApiConstants.products,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (cat != null && cat.isNotEmpty) 'category': cat,
          if (sub != null && sub.isNotEmpty) 'subcategory': sub,
          if (s != null && s.isNotEmpty) 'sort': s,
        },
      );
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load products');
    }
  }

  /// Fetch a single product by ID.
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _client.dio.get(ApiConstants.productById(id));
      return ProductModel.fromJson(
        response.data['data'] as Map<String, dynamic>? ?? response.data,
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load product');
    }
  }

  /// Create a new product.
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.products,
        data: data,
      );
      return ProductModel.fromJson(
        response.data['data'] as Map<String, dynamic>? ?? response.data,
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to create product');
    }
  }

  /// Update an existing product.
  Future<ProductModel> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.dio.put(
        ApiConstants.productById(id),
        data: data,
      );
      return ProductModel.fromJson(
        response.data['data'] as Map<String, dynamic>? ?? response.data,
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update product');
    }
  }

  /// Delete a product.
  Future<void> deleteProduct(String id) async {
    try {
      await _client.dio.delete(ApiConstants.productById(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete product');
    }
  }
}
