import '../../../../core/localization/locale_cubit.dart';

/// Product model for the store catalog.
class ProductModel {
  final String id;
  final String name;
  final String? size;
  final String? description;
  final double price;
  final double? salePrice;
  final double? discount;
  final String? cover;
  final List<String> images;
  final double ratingAvg;
  final int ratingCount;
  final String? category;
  final String? categoryId;
  final String? subcategory;
  final String? subcategoryId;
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
    this.discount,
    this.cover,
    this.images = const [],
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.category,
    this.categoryId,
    this.subcategory,
    this.subcategoryId,
    this.quantity = 0,
    this.sold = 0,
    this.inStock = true,
  });

  bool get onSale => salePrice != null && salePrice! > 0 && salePrice! < price;

  double get displayPrice => onSale ? salePrice! : price;

  double get discountPercent =>
      onSale ? ((price - salePrice!) / price * 100) : (discount ?? 0);

  int get discountPercentage => discount?.round() ?? discountPercent.round();

  double get savingsAmount => onSale ? (price - salePrice!) : 0.0;

  static String _parseLocalized(dynamic value, [String defaultVal = '']) {
    if (value == null) return defaultVal;
    if (value is String) return value;
    if (value is Map) {
      final lang = LocaleCubit.currentLanguage;
      if (value[lang] != null) return value[lang].toString();
      if (value['en'] != null) return value['en'].toString();
      if (value['ar'] != null) return value['ar'].toString();
      if (value.isNotEmpty) return value.values.first.toString();
    }
    return value.toString();
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final parsedDiscount = (json['discount'] as num?)?.toDouble();
    final pad =
        (json['priceAfterDiscount'] as num?)?.toDouble() ??
        (json['salePrice'] as num?)?.toDouble();
    double? salePrice = (pad != null && pad > 0 && pad < price) ? pad : null;
    if (salePrice == null && parsedDiscount != null && parsedDiscount > 0 && parsedDiscount < 100) {
      salePrice = price * (1 - parsedDiscount / 100);
    }

    final quantity =
        (json['quantity'] as num?)?.toInt() ??
        (json['stock'] as num?)?.toInt() ??
        (json['countInStock'] as num?)?.toInt() ??
        0;

    return ProductModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: _parseLocalized(json['name'] ?? json['title']),
      size: json['size']?.toString(),
      description: json['description'] != null
          ? _parseLocalized(json['description'])
          : null,
      price: price,
      salePrice: salePrice,
      discount: parsedDiscount,
      cover: json['cover'] as String? ?? json['imageCover'] as String?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      ratingAvg:
          (json['rateAvg'] as num?)?.toDouble() ??
          (json['ratingsAverage'] as num?)?.toDouble() ??
          0.0,
      ratingCount:
          (json['rating'] as num?)?.toInt() ??
          (json['ratingsQuantity'] as num?)?.toInt() ??
          0,
      category: json['category'] is Map
          ? _parseLocalized(json['category']['name'])
          : json['category']?.toString(),
      categoryId: json['categoryId']?.toString() ??
          (json['category'] is Map
              ? (json['category']['_id']?.toString() ??
                  json['category']['id']?.toString())
              : (json['category'] != null &&
                      json['category'].toString().length == 24
                  ? json['category'].toString()
                  : null)),
      subcategory: json['subcategory'] is Map
          ? _parseLocalized(json['subcategory']['name'])
          : json['subcategory']?.toString(),
      subcategoryId: json['subcategoryId']?.toString() ??
          (json['subcategory'] is Map
              ? (json['subcategory']['_id']?.toString() ??
                  json['subcategory']['id']?.toString())
              : (json['subcategory'] != null &&
                      json['subcategory'].toString().length == 24
                  ? json['subcategory'].toString()
                  : null)),
      quantity: quantity,
      sold: (json['sold'] as num?)?.toInt() ?? 0,
      inStock: (json['inStock'] as bool?) ?? quantity > 0,
    );
  }
}
