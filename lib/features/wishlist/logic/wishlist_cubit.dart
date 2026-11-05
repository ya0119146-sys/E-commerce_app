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
  Future<void> toggleWishlist(String productId, [ProductModel? product]) async {
    final currentIds = Set<String>.from(state.wishlistIds);
    final currentProducts = List<ProductModel>.from(state.products);
    final wasInWishlist = currentIds.contains(productId);

    // Optimistic update
    if (wasInWishlist) {
      currentIds.remove(productId);
      currentProducts.removeWhere((p) => p.id == productId);
    } else {
      currentIds.add(productId);
      if (product != null && !currentProducts.any((p) => p.id == productId)) {
        currentProducts.insert(0, product);
      }
    }

    emit(
      state.copyWith(
        wishlistIds: currentIds,
        products: currentProducts,
        status: WishlistStatus.loaded,
      ),
    );

    try {
      final updatedProducts = await _repository.toggleWishlist(
        productId,
        isInWishlist: wasInWishlist,
      );
      if (updatedProducts.isNotEmpty) {
        final newIds = updatedProducts.map((p) => p.id).toSet();
        emit(state.copyWith(products: updatedProducts, wishlistIds: newIds));
      }
    } catch (_) {
      // Revert on error
      if (wasInWishlist) {
        if (product != null && !currentProducts.any((p) => p.id == productId)) {
          currentProducts.add(product);
        }
        currentIds.add(productId);
      } else {
        currentIds.remove(productId);
        currentProducts.removeWhere((p) => p.id == productId);
      }
      emit(state.copyWith(wishlistIds: currentIds, products: currentProducts));
    }
  }

  /// Reset wishlist state to empty (e.g. on logout).
  void clearWishlist() {
    emit(const WishlistState());
  }
}
