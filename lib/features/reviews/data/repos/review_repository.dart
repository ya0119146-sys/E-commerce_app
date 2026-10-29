import 'package:dio/dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/review_model.dart';

/// Repository for review-related API calls.
class ReviewRepository {
  final DioClient _client;

  ReviewRepository(this._client);

  /// Get all reviews.
  Future<List<ReviewModel>> getAllReviews() async {
    try {
      final response = await _client.dio.get(ApiConstants.reviews);
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load reviews');
    }
  }

  /// Get review details by ID.
  Future<ReviewModel> getReviewById(String id) async {
    try {
      final response = await _client.dio.get('${ApiConstants.reviews}/$id');
      final data = response.data['data'] ?? response.data;
      return ReviewModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load review details');
    }
  }

  /// Get reviews for a specific product.
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final response = await _client.dio.get(
        ApiConstants.reviewsByProductId(productId),
      );
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load product reviews');
    }
  }

  /// Get my reviews.
  Future<List<ReviewModel>> getMyReviews() async {
    try {
      final response = await _client.dio.get(ApiConstants.reviewsMe);
      final data = response.data['data'] as List? ?? [];
      return data
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to load your reviews');
    }
  }

  /// Create a review.
  Future<ReviewModel> createReview(
    String comment,
    double rate,
    String productId,
  ) async {
    try {
      final response = await _client.dio.post(
        ApiConstants.reviews,
        data: {'comment': comment, 'rate': rate, 'product': productId},
      );
      return ReviewModel.fromJson(
        response.data['data'] as Map<String, dynamic>? ?? response.data,
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to create review');
    }
  }

  /// Update a review.
  Future<ReviewModel> updateReview(
    String id,
    String comment,
    double rate,
  ) async {
    try {
      final response = await _client.dio.put(
        '${ApiConstants.reviews}/$id',
        data: {'comment': comment, 'rate': rate},
      );
      return ReviewModel.fromJson(
        response.data['data'] as Map<String, dynamic>? ?? response.data,
      );
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to update review');
    }
  }

  /// Delete a review.
  Future<void> deleteReview(String id) async {
    try {
      await _client.dio.delete('${ApiConstants.reviews}/$id');
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          const ApiException(message: 'Failed to delete review');
    }
  }
}
