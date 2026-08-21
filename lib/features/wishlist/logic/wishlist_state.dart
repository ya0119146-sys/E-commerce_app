part of 'wishlist_cubit.dart';

enum WishlistStatus { initial, loading, loaded, error }

class WishlistState extends Equatable {
  final WishlistStatus status;
  final List<ProductModel> products;
  final Set<String> wishlistIds;
  final String? errorMessage;

  const WishlistState({
    this.status = WishlistStatus.initial,
    this.products = const [],
    this.wishlistIds = const {},
    this.errorMessage,
  });

  bool isInWishlist(String productId) => wishlistIds.contains(productId);

  WishlistState copyWith({
    WishlistStatus? status,
    List<ProductModel>? products,
    Set<String>? wishlistIds,
    String? errorMessage,
  }) {
    return WishlistState(
      status: status ?? this.status,
      products: products ?? this.products,
      wishlistIds: wishlistIds ?? this.wishlistIds,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products.length, wishlistIds.length];
}
