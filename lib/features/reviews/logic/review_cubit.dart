import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/review_repository.dart';
import '../../../core/network/api_exception.dart';
import 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _repository;

  ReviewCubit(this._repository) : super(ReviewInitial());

  /// Fetch all reviews.
  // Future<void> fetchAllReviews() async {
  //   emit(ReviewLoading());
  //   try {
  //     final reviews = await _repository.getAllReviews();
  //     emit(ReviewLoaded(reviews));
  //   } on ApiException catch (e) {
  //     emit(ReviewError(e.message));
  //   } catch (e) {
  //     emit(const ReviewError('Failed to load reviews.'));
  //   }
  // }

  /// Fetch reviews for a specific product.
  Future<void> fetchProductReviews(String productId) async {
    emit(ReviewLoading());
    try {
      final reviews = await _repository.getProductReviews(productId);
      emit(ReviewLoaded(reviews));
    } on ApiException catch (e) {
      emit(ReviewError(e.message));
    } catch (e) {
      emit(const ReviewError('Failed to load product reviews.'));
    }
  }

  /// Fetch my reviews.
  Future<void> fetchMyReviews() async {
    emit(ReviewLoading());
    try {
      final reviews = await _repository.getMyReviews();
      emit(ReviewLoaded(reviews));
    } on ApiException catch (e) {
      emit(ReviewError(e.message));
    } catch (e) {
      emit(const ReviewError('Failed to load your reviews.'));
    }
  }

  /// Create a review.
  Future<void> createReview(
    String comment,
    double rate,
    String productId,
  ) async {
    emit(ReviewLoading());
    try {
      await _repository.createReview(comment, rate, productId);
      emit(const ReviewActionSuccess('Review created successfully!'));
    } on ApiException catch (e) {
      emit(ReviewError(e.message));
    } catch (e) {
      emit(const ReviewError('Failed to create review.'));
    }
  }

  /// Update a review.
  Future<void> updateReview(String id, String review, double rating) async {
    emit(ReviewLoading());
    try {
      await _repository.updateReview(id, review, rating);
      emit(const ReviewActionSuccess('Review updated successfully!'));
    } on ApiException catch (e) {
      emit(ReviewError(e.message));
    } catch (e) {
      emit(const ReviewError('Failed to update review.'));
    }
  }

  /// Delete a review.
  Future<void> deleteReview(String id) async {
    emit(ReviewLoading());
    try {
      await _repository.deleteReview(id);
      emit(const ReviewActionSuccess('Review deleted successfully!'));
    } on ApiException catch (e) {
      emit(ReviewError(e.message));
    } catch (e) {
      emit(const ReviewError('Failed to delete review.'));
    }
  }
}
