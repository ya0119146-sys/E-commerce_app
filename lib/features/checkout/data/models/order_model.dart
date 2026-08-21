import 'address_model.dart';

/// Order model for order history and details.
class OrderModel {
  final String id;
  final double totalPrice;
  final double itemsPrice;
  final double taxPrice;
  final String? status;
  final DateTime? createdAt;
  final List<OrderItemModel> items;
  final bool isPaid;
  final bool isDelivered;
  final String paymentMethod;
  final AddressModel? address;
  final String? userName;
  final String? userImage;
  final String? userId;

  const OrderModel({
    required this.id,
    this.totalPrice = 0,
    this.itemsPrice = 0,
    this.taxPrice = 0,
    this.status,
    this.createdAt,
    this.items = const [],
    this.isPaid = false,
    this.isDelivered = false,
    this.paymentMethod = 'cash',
    this.address,
    this.userName,
    this.userImage,
    this.userId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final addr = json['address'];
    return OrderModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      itemsPrice: (json['itemsPrice'] as num?)?.toDouble() ?? 0,
      taxPrice: (json['taxPrice'] as num?)?.toDouble() ?? 0,
      status: (json['isDelivered'] == true) ? 'delivered' : 'pending',
      isPaid: json['isPaid'] as bool? ?? false,
      isDelivered: json['isDelivered'] as bool? ?? false,
      paymentMethod: json['payment'] as String? ?? 'cash',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
              ?.add(const Duration(hours: 3))
          : null,
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      address: addr is Map
          ? AddressModel.fromJson(addr as Map<String, dynamic>)
          : null,
      userName: user is Map ? user['name'] as String? : null,
      userImage: user is Map ? user['image'] as String? : null,
      userId: user is Map ? user['_id'] as String? : null,
    );
  }

  // Backwards compatibility getters
  double get subtotal => itemsPrice;
  double get tax => taxPrice;
  double get shipping => 0;
  AddressModel? get shippingAddress => address;
}

class OrderItemModel {
  final String productId;
  final String? title;
  final String? image;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.productId,
    this.title,
    this.image,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    return OrderItemModel(
      productId: product is Map
          ? (product['_id'] as String? ?? product['id'] as String? ?? '')
          : (product as String? ?? ''),
      title: product is Map
          ? (product['name'] as String? ?? product['title'] as String?)
          : null,
      image: product is Map ? product['cover'] as String? : null,
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
