/// Product model for the store catalog.
class ProductModel {
  final String id;
  final String name;
  final String? size;
  final String? description;
  final double price;
  final double? salePrice;
  final String? cover;
  final List<String> images;
  final double ratingAvg;
  final int ratingCount;
  final String? category;
  final String? subcategory;
  final int quantity;
  final int sold;
  final bool inStock;

  const ProductModel({
    required this.id,
    required this.name,
    this.size,
    this.description,
    required this.price,
    this.salePrice,
    this.cover,
    this.images = const [],
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.category,
    this.subcategory,
    this.quantity = 0,
    this.sold = 0,
    this.inStock = true,
  });

  bool get onSale => salePrice != null && salePrice! > 0 && salePrice! < price;

  double get displayPrice => onSale ? salePrice! : price;

  double get discountPercent =>
      onSale ? ((price - salePrice!) / price * 100) : 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final pad = (json['priceAfterDiscount'] as num?)?.toDouble() ??
        (json['salePrice'] as num?)?.toDouble();
    final salePrice = (pad != null && pad > 0 && pad < price) ? pad : null;

    return ProductModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      size: json['size'] as String?,
      description: json['description'] as String?,
      price: price,
      salePrice: salePrice,
      cover: json['cover'] as String? ?? json['imageCover'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ratingAvg: (json['rateAvg'] as num?)?.toDouble() ??
          (json['ratingsAverage'] as num?)?.toDouble() ??
          0.0,
      ratingCount: (json['rating'] as num?)?.toInt() ??
          (json['ratingsQuantity'] as num?)?.toInt() ??
          0,
      category: json['category'] is Map
          ? json['category']['name'] as String?
          : json['category'] as String?,
      subcategory: json['subcategory'] is Map
          ? json['subcategory']['name'] as String?
          : json['subcategory'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      sold: (json['sold'] as num?)?.toInt() ?? 0,
      inStock: ((json['quantity'] as num?)?.toInt() ?? 0) > 0,
    );
  }
}
