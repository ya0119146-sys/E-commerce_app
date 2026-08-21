part of 'cart_cubit.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final CartModel cart;
  final int cartItemCount;
  final bool cartPulse;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.cart = CartModel.empty,
    this.cartItemCount = 0,
    this.cartPulse = false,
    this.errorMessage,
  });

  CartState copyWith({
    CartStatus? status,
    CartModel? cart,
    int? cartItemCount,
    bool? cartPulse,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      cartPulse: cartPulse ?? this.cartPulse,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, cart.items.length, cartItemCount, cartPulse, errorMessage];
}
