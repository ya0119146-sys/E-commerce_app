import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/cart_model.dart';
import '../data/repos/cart_repository.dart';
import '../../../core/network/api_exception.dart';

part 'cart_state.dart';

/// Cart Cubit — manages shopping cart with optimistic UI.
class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;

  CartCubit(this._repository) : super(const CartState());

  /// Fetch current cart.
  Future<void> fetchCart() async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final cart = await _repository.getCart();
      emit(state.copyWith(status: CartStatus.loaded, cart: cart));
    } on ApiException catch (e) {
      emit(state.copyWith(status: CartStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: CartStatus.error,
          errorMessage: 'Failed to load cart',
        ),
      );
    }
  }

  /// Add a product to cart (optimistic).
  Future<void> addToCart(String productId) async {
    // Optimistic: increment badge count immediately
    emit(
      state.copyWith(cartItemCount: state.cartItemCount + 1, cartPulse: true),
    );

    try {
      final cart = await _repository.addToCart(productId);
      final mergedCart = _mergeWithOldCart(cart, state.cart);
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: mergedCart,
          cartItemCount: mergedCart.itemCount,
          cartPulse: false,
        ),
      );
    } on ApiException catch (e) {
      // Revert optimistic update
      emit(
        state.copyWith(
          cartItemCount: state.cartItemCount - 1,
          cartPulse: false,
          errorMessage: e.message,
        ),
      );
    }
  }

  /// Update quantity of a cart item (optimistic).
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity < 1) return;
    final oldCart = state.cart;

    // Optimistic update
    final updatedItems = oldCart.items.map((item) {
      if (item.productId == productId) {
        return CartItemModel(
          id: item.id,
          product: item.product,
          productId: item.productId,
          quantity: quantity,
          price: item.price,
        );
      }
      return item;
    }).toList();

    final newTotalPrice = updatedItems.fold(0.0, (s, i) => s + i.totalPrice);
    emit(
      state.copyWith(
        cart: CartModel(
          id: oldCart.id,
          items: updatedItems,
          totalPrice: newTotalPrice,
          taxPrice: updatedItems.isEmpty
              ? 0.0
              : (newTotalPrice >= 1000 ? 0.0 : 100.0),
        ),
      ),
    );

    try {
      final cart = await _repository.updateQuantity(productId, quantity);
      final mergedCart = _mergeWithOldCart(cart, oldCart);
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: mergedCart,
          cartItemCount: mergedCart.itemCount,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(cart: oldCart, errorMessage: e.message));
    }
  }

  /// Remove item from cart.
  Future<void> removeFromCart(String productId) async {
    final oldCart = state.cart;
    final updatedItems = oldCart.items
        .where((i) => i.productId != productId)
        .toList();
    final newTotalPrice = updatedItems.fold(0.0, (s, i) => s + i.totalPrice);
    emit(
      state.copyWith(
        cart: CartModel(
          id: oldCart.id,
          items: updatedItems,
          totalPrice: newTotalPrice,
          taxPrice: updatedItems.isEmpty
              ? 0.0
              : (newTotalPrice >= 1000 ? 0.0 : 100.0),
        ),
        cartItemCount: updatedItems.fold<int>(0, (s, i) => s + i.quantity),
      ),
    );

    try {
      final cart = await _repository.removeFromCart(productId);
      final mergedCart = _mergeWithOldCart(cart, oldCart);
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: mergedCart,
          cartItemCount: mergedCart.itemCount,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(cart: oldCart, errorMessage: e.message));
    }
  }

  /// Merge incoming cart items with existing populated product models if the
  /// server response returned unpopulated ObjectId strings for products.
  CartModel _mergeWithOldCart(CartModel newCart, CartModel oldCart) {
    if (oldCart.items.isEmpty) return newCart;
    final oldProductMap = {
      for (final item in oldCart.items)
        if (item.product != null) item.productId: item.product!,
    };
    if (oldProductMap.isEmpty) return newCart;

    final mergedItems = newCart.items.map((item) {
      if (item.product == null && oldProductMap.containsKey(item.productId)) {
        return CartItemModel(
          id: item.id,
          product: oldProductMap[item.productId],
          productId: item.productId,
          quantity: item.quantity,
          price: item.price,
        );
      }
      return item;
    }).toList();

    return CartModel(
      id: newCart.id ?? oldCart.id,
      items: mergedItems,
      totalPrice: newCart.totalPrice,
      taxPrice: newCart.taxPrice,
      totalPriceAfterDiscount: newCart.totalPriceAfterDiscount,
    );
  }

  /// Clear entire cart.
  Future<void> clearCart() async {
    final oldCart = state.cart;
    emit(state.copyWith(cart: CartModel.empty, cartItemCount: 0));

    try {
      await _repository.clearCart();
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: CartModel.empty,
          cartItemCount: 0,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(cart: oldCart, errorMessage: e.message));
    }
  }

  /// Reset pulse flag.
  void resetPulse() {
    emit(state.copyWith(cartPulse: false));
  }
}
