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
      product: productData is Map
          ? ProductModel.fromJson(Map<String, dynamic>.from(productData))
          : null,
      productId: productData is Map
          ? (productData['_id']?.toString() ??
                productData['id']?.toString() ??
                '')
          : (productData?.toString() ?? ''),
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

  /// Tax/delivery fee from backend (100 if subtotal < 1000, 0 if free delivery).
  double get effectiveTaxPrice {
    if (items.isEmpty) return 0.0;
    return taxPrice ?? (totalPrice >= 1000 ? 0.0 : 100.0);
  }

  /// Final total including the backend delivery/tax fee.
  double get finalTotal => totalPrice + effectiveTaxPrice;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // Backend field is 'items' (not 'cartItems').
    final cartItems = (json['items'] as List? ?? [])
        .whereType<Map>()
        .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return CartModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      items: cartItems,
      // Backend uses 'totelPrice' (typo — not 'totalCartPrice' or 'totalPrice').
      totalPrice:
          (json['totelPrice'] as num?)?.toDouble() ??
          cartItems.fold(0.0, (sum, item) => sum + item.totalPrice),
      taxPrice: (json['taxPrice'] as num?)?.toDouble(),
      // Backend uses 'totelPriceAfterDiscount' (may be null).
      totalPriceAfterDiscount: (json['totelPriceAfterDiscount'] as num?)
          ?.toDouble(),
    );
  }

  static const empty = CartModel();
}
