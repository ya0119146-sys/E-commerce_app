import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repos/wishlist_repository.dart';
import '../../store/data/models/product_model.dart';
import '../../../core/network/api_exception.dart';

part 'wishlist_state.dart';

/// Wishlist Cubit — manages wishlist with optimistic toggle.
class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRepository _repository;

  WishlistCubit(this._repository) : super(const WishlistState());

  /// Fetch wishlist from server.
  Future<void> fetchWishlist() async {
    emit(state.copyWith(status: WishlistStatus.loading));
    try {
      final products = await _repository.getWishlist();
      final ids = products.map((p) => p.id).toSet();
      emit(
        state.copyWith(
          status: WishlistStatus.loaded,
          products: products,
          wishlistIds: ids,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(status: WishlistStatus.error, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: WishlistStatus.error,
          errorMessage: 'Failed to load wishlist',
        ),
      );
    }
  }

  /// Optimistic toggle — update UI immediately, then sync with server.
  Future<void> toggleWishlist(String productId) async {
    final currentIds = Set<String>.from(state.wishlistIds);
    final currentProducts = List<ProductModel>.from(state.products);
    final wasInWishlist = currentIds.contains(productId);

    // Optimistic update
    if (wasInWishlist) {
      currentIds.remove(productId);
      currentProducts.removeWhere((p) => p.id == productId);
    } else {
      currentIds.add(productId);
      // Note: If we are adding back an item we just removed, we don't have the full ProductModel
      // unless we store it. But usually, adding happens from Home/Detail.
      // If we are in Wishlist screen, we only care about removals.
    }

    emit(state.copyWith(wishlistIds: currentIds, products: currentProducts));

    try {
      final updatedIds = await _repository.toggleWishlist(productId);
      // After sync, we might want to re-fetch or just trust the IDs.
      // To keep products in sync with the server list:
      emit(state.copyWith(wishlistIds: updatedIds.toSet()));
    } catch (_) {
      // Revert on error
      if (wasInWishlist) {
        // Re-fetching is safer if we need to revert a removal
        fetchWishlist();
      } else {
        currentIds.remove(productId);
        emit(state.copyWith(wishlistIds: currentIds));
      }
    }
  }
}
