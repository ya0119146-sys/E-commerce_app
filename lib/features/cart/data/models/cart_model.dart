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
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Cart model wrapping the list of items.
class CartModel {
  final String? id;
  final List<CartItemModel> items;
  final double totalPrice;

  const CartModel({this.id, this.items = const [], this.totalPrice = 0.0});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final cartItems =
        (json['cartItems'] as List? ?? json['items'] as List? ?? [])
            .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
    return CartModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      items: cartItems,
      totalPrice:
          (json['totalCartPrice'] as num?)?.toDouble() ??
          cartItems.fold(0.0, (sum, item) => sum + item.totalPrice),
    );
  }

  static const empty = CartModel();
}
