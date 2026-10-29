import 'package:e_commerce/features/store/data/models/product_model.dart';
import 'package:equatable/equatable.dart';

/// Review model for product reviews.
class ReviewModel extends Equatable {
  final String id;
  final String comment;
  final double rate;
  final String name;
  final String? userEmail;
  final String? userId;
  final ProductModel product;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.comment,
    required this.rate,
    required this.name,
    this.userEmail,
    this.userId,
    required this.product,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final productData = json['product'];
    ProductModel product;
    if (productData is Map<String, dynamic>) {
      product = ProductModel.fromJson(productData);
    } else if (productData is String) {
      product = ProductModel(
        id: productData,
        name: '',
        price: 0,
      );
    } else {
      product = const ProductModel(
        id: '',
        name: '',
        price: 0,
      );
    }

    return ReviewModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      name: json['user'] is Map
          ? json['user']['name'] as String? ?? ''
          : json['user'] as String? ?? '',
      userEmail: json['user'] is Map ? json['user']['email'] as String? : null,
      userId: json['user'] is Map
          ? (json['user']['_id'] as String? ?? json['user']['id'] as String?)
          : (json['user'] as String?),
      product: product,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
              ?.add(const Duration(hours: 3))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'comment': comment, 'rate': rate, 'product': product.id};
  }

  @override
  List<Object?> get props =>
      [id, comment, rate, name, userEmail, userId, product];
}
