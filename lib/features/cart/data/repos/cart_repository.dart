import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cart_model.dart';

/// Repository for cart operations.
class CartRepository {
  final DioClient _client;

  CartRepository(this._client);

  /// Get current cart.
  /// If the cart is empty, the backend returns HTTP 404, which is treated
  /// as an empty cart state rather than an error.
  Future<CartModel> getCart() async {
    try {
      final response = await _client.dio.get(ApiConstants.cart);
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return CartModel.fromJson(data);
      }
      return CartModel.empty;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          (e.error is ApiException &&
              (e.error as ApiException).statusCode == 404)) {
        return CartModel.empty;
      }
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load cart');
    }
  }

  /// Add product to cart.
  Future<CartModel> addToCart(String productId) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.addToCart,
        data: {'productId': productId},
      );
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return CartModel.fromJson(data);
      }
      return CartModel.empty;
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to add to cart');
    }
  }

  /// Update item quantity.
  Future<CartModel> updateQuantity(String productId, int quantity) async {
    try {
      final response = await _client.dio.patch(
        ApiConstants.updateCart,
        data: {'productId': productId, 'quantity': quantity},
      );
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return CartModel.fromJson(data);
      }
      return CartModel.empty;
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update cart');
    }
  }

  /// Remove item from cart.
  Future<CartModel> removeFromCart(String productId) async {
    try {
      final response = await _client.dio.patch(
        ApiConstants.removeFromCart,
        data: {"productId": productId},
      );
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return CartModel.fromJson(data);
      }
      return CartModel.empty;
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to remove from cart');
    }
  }

  /// Clear entire cart.
  Future<void> clearCart() async {
    try {
      await _client.dio.delete(ApiConstants.deleteCart);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to clear cart');
    }
  }
}
