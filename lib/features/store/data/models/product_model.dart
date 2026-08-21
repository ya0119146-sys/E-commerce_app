/// Product model for the store catalog.
class ProductModel {
  final String id;
  final String name;
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

  bool get onSale => salePrice != null && salePrice! < price;

  double get displayPrice => salePrice ?? price;

  double get discountPercent =>
      onSale ? ((price - salePrice!) / price * 100) : 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      salePrice: json['salePrice'] != null
          ? (json['salePrice'] as num).toDouble()
          : null,
      cover: json['cover'] as String? ?? json['imageCover'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ratingAvg: (json['rateAvg'] as num?)?.toDouble() ??
          (json['ratingsAverage'] as num?)?.toDouble() ??
          0.0,
      ratingCount: json['rating'] as int? ?? json['ratingsQuantity'] as int? ?? 0,
      category: json['category'] is Map
          ? json['category']['name'] as String?
          : json['category'] as String?,
      subcategory: json['subcategory'] is Map
          ? json['subcategory']['name'] as String?
          : json['subcategory'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      sold: json['sold'] as int? ?? 0,
      inStock: (json['quantity'] as int? ?? 0) > 0,
    );
  }
}
