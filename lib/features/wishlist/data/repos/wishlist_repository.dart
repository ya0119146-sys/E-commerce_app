import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../store/data/models/product_model.dart';

/// Repository for wishlist operations.
class WishlistRepository {
  final DioClient _client;

  WishlistRepository(this._client);

  /// Get all wishlist products.
  Future<List<ProductModel>> getWishlist() async {
    try {
      final response = await _client.dio.get(ApiConstants.getWishlist);
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load wishlist');
    }
  }

  /// Add product to wishlist.
  /// Backend returns the updated list of populated product objects.
  Future<List<ProductModel>> addToWishlist(String productId) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.addToWishlist,
        data: {'productId': productId},
      );
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to add to wishlist');
    }
  }

  /// Remove product from wishlist.
  /// Backend returns the remaining list of populated product objects.
  Future<List<ProductModel>> removeFromWishlist(String productId) async {
    try {
      final response = await _client.dio.delete(
        ApiConstants.deleteWishlist(productId),
      );
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to remove from wishlist');
    }
  }

  /// Toggle product in wishlist (calls remove if already present, add otherwise).
  Future<List<ProductModel>> toggleWishlist(
    String productId, {
    required bool isInWishlist,
  }) async {
    if (isInWishlist) {
      return removeFromWishlist(productId);
    } else {
      return addToWishlist(productId);
    }
  }
}
