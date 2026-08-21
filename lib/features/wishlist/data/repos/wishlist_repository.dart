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

  /// Toggle product in wishlist.
  Future<List<String>> toggleWishlist(String productId) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.getWishlist,
        data: {'productId': productId},
      );
      final data = response.data['data'] as List? ?? [];
      return data.map((e) => e.toString()).toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update wishlist');
    }
  }
}
