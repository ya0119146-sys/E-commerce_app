import '../../../store/data/models/product_model.dart';

/// Cart item model.
class CartItemModel {
  final String id;
  final ProductModel? product;
  final String productId;
  final int quantity;
  final double price;

  const CartItemModel({
    required this.id,
    this.product,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  double get totalPrice => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productData = json['product'];
    return CartItemModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      product: productData is Map<String, dynamic>
          ? ProductModel.fromJson(productData)
          : null,
      productId: productData is Map<String, dynamic>
          ? (productData['_id'] as String? ?? '')
          : (productData as String? ?? ''),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Cart model wrapping the list of items.
class CartModel {
  final String? id;
  final List<CartItemModel> items;
  final double totalPrice;
  final double? taxPrice;
  final double? totalPriceAfterDiscount;

  const CartModel({
    this.id,
    this.items = const [],
    this.totalPrice = 0.0,
    this.taxPrice,
    this.totalPriceAfterDiscount,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // Backend field is 'items' (not 'cartItems').
    final cartItems = (json['items'] as List? ?? [])
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return CartModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      items: cartItems,
      // Backend uses 'totelPrice' (typo — not 'totalCartPrice' or 'totalPrice').
      totalPrice: (json['totelPrice'] as num?)?.toDouble() ??
          cartItems.fold(0.0, (sum, item) => sum + item.totalPrice),
      taxPrice: (json['taxPrice'] as num?)?.toDouble(),
      // Backend uses 'totelPriceAfterDiscount' (may be null).
      totalPriceAfterDiscount:
          (json['totelPriceAfterDiscount'] as num?)?.toDouble(),
    );
  }

  static const empty = CartModel();
}
