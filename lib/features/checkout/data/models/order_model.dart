import '../../../../core/constants/egypt_governorates.dart';
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
  final bool isDepositePaid;
  final double depositeAmount;
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
    this.isDepositePaid = false,
    this.depositeAmount = 0,
    this.paymentMethod = 'cash',
    this.address,
    this.userName,
    this.userImage,
    this.userId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final addr = json['address'];
    final rawTotalPrice = (json['totalPrice'] as num?)?.toDouble() ?? 0;
    final rawItemsPrice = (json['itemsPrice'] as num?)?.toDouble() ?? 0;
    var parsedTaxPrice = (json['taxPrice'] as num?)?.toDouble() ?? 0;

    final parsedAddress = addr is Map
        ? AddressModel.fromJson(Map<String, dynamic>.from(addr))
        : null;

    if (parsedTaxPrice == 0 &&
        parsedAddress != null &&
        parsedAddress.state.isNotEmpty &&
        !EgyptGovernorates.isSharqia(parsedAddress.state)) {
      parsedTaxPrice = EgyptGovernorates.getShippingFee(parsedAddress.state);
    }

    final effectiveTotal = (rawTotalPrice > 0 && rawTotalPrice > rawItemsPrice)
        ? rawTotalPrice
        : (rawItemsPrice + parsedTaxPrice);

    return OrderModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      totalPrice: effectiveTotal,
      itemsPrice: rawItemsPrice,
      taxPrice: parsedTaxPrice,
      status: (json['isDelivered'] == true) ? 'delivered' : 'pending',
      isPaid: json['isPaid'] as bool? ?? false,
      isDelivered: json['isDelivered'] as bool? ?? false,
      isDepositePaid: json['isDepositePaid'] as bool? ?? false,
      depositeAmount:
          (json['DepositeAmount'] as num?)?.toDouble() ??
          (json['depositeAmount'] as num?)?.toDouble() ??
          0,
      paymentMethod: json['payment'] as String? ?? 'cash',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(
              json['createdAt'] as String,
            )?.add(const Duration(hours: 3))
          : null,
      items: (json['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      address: parsedAddress,
      userName: user is Map ? user['name']?.toString() : null,
      userImage: user is Map ? user['image']?.toString() : null,
      userId: user is Map
          ? (user['_id']?.toString() ?? user['id']?.toString())
          : null,
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
          ? (product['_id']?.toString() ?? product['id']?.toString() ?? '')
          : (product?.toString() ?? ''),
      title: product is Map
          ? (product['name'] as String? ?? product['title'] as String?)
          : null,
      image: product is Map ? product['cover'] as String? : null,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
