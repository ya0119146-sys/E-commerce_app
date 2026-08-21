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
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          cartItemCount: cart.itemCount,
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

    emit(
      state.copyWith(
        cart: CartModel(
          id: oldCart.id,
          items: updatedItems,
          totalPrice: updatedItems.fold(0.0, (s, i) => s + i.totalPrice),
        ),
      ),
    );

    try {
      final cart = await _repository.updateQuantity(productId, quantity);
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          cartItemCount: cart.itemCount,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(cart: oldCart, errorMessage: e.message));
    }
  }

  /// Remove item from cart.
  Future<void> removeFromCart(String productId) async {
    final oldCart = state.cart;
    final updatedItems = oldCart.items.where((i) => i.productId != productId).toList();
    emit(
      state.copyWith(
        cart: CartModel(
          id: oldCart.id,
          items: updatedItems,
          totalPrice: updatedItems.fold(0.0, (s, i) => s + i.totalPrice),
        ),
        cartItemCount: updatedItems.fold<int>(0, (s, i) => s + i.quantity),
      ),
    );

    try {
      final cart = await _repository.removeFromCart(productId);
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          cartItemCount: cart.itemCount,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(cart: oldCart, errorMessage: e.message));
    }
  }

  /// Clear entire cart.
  Future<void> clearCart() async {
    final oldCart = state.cart;
    emit(
      state.copyWith(
        cart: CartModel.empty,
        cartItemCount: 0,
      ),
    );

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
