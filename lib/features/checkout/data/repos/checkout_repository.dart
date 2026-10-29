import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/address_model.dart';
import '../models/order_model.dart';

/// Repository for checkout and order operations.
class CheckoutRepository {
  final DioClient _client;

  CheckoutRepository(this._client);

  /// Get saved addresses.
  /// If the user has no saved addresses, the backend returns HTTP 404,
  /// which is treated as an empty address list.
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _client.dio.get(ApiConstants.address);
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          (e.error is ApiException &&
              (e.error as ApiException).statusCode == 404)) {
        return [];
      }
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load addresses');
    }
  }

  /// Add a new address.
  /// Backend expects: { "address": { street, city, state, zip } }
  /// The address OBJECT must be nested inside the 'address' key — NOT an array.
  Future<void> addAddress(
    String street,
    String city,
    String state,
    String zip,
  ) async {
    try {
      await _client.dio.post(
        ApiConstants.address,
        data: {
          'address': {
            'street': street,
            'city': city,
            'state': state,
            'zip': zip,
          },
        },
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to add address');
    }
  }

  /// Remove an address.
  Future<void> removeAddress(String id) async {
    try {
      await _client.dio.delete(ApiConstants.addressDelete(id));
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to remove address');
    }
  }

  /// Place an order.
  /// Backend expects: `{ "address": "addressId" }`
  /// The address must be the MongoDB _id of the user's saved address — NOT the full object.
  Future<OrderModel> placeOrder(
    String street,
    String city,
    String state,
    String zip,
    String id,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.order,
        data: {
          'address': id, // ⚠️ must be the address _id string, not an object
        },
      );
      final data = response.data['data'] ?? response.data;
      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to place order');
    }
  }

  /// Get order history.
  Future<List<OrderModel>> getOrderHistory() async {
    try {
      final response = await _client.dio.get(ApiConstants.order);
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load orders');
    }
  }

  /// Get order details.
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _client.dio.get(ApiConstants.orderDetails(id));
      final data = response.data['data'] ?? response.data;
      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load order details');
    }
  }

  /// Mark order as delivered.
  Future<OrderModel> deliverOrder(String id) async {
    try {
      final response = await _client.dio.patch(ApiConstants.orderDeliver(id));
      final data = response.data['data'] ?? response.data;
      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to confirm delivery');
    }
  }

  /// Mark order as paid.
  Future<OrderModel> payOrder(String id) async {
    try {
      final response = await _client.dio.patch(ApiConstants.orderPay(id));
      final data = response.data['data'] ?? response.data;
      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to confirm payment');
    }
  }
}
