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

  static bool isHexObjectId(String? s) {
    if (s == null || s.length != 24) return false;
    for (var i = 0; i < 24; i++) {
      final c = s.codeUnitAt(i);
      final isHex =
          (c >= 48 && c <= 57) || (c >= 97 && c <= 102) || (c >= 65 && c <= 70);
      if (!isHex) return false;
    }
    return true;
  }

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
    if (salePrice == null &&
        parsedDiscount != null &&
        parsedDiscount > 0 &&
        parsedDiscount < 100) {
      salePrice = price * (1 - parsedDiscount / 100);
    }

    final quantity =
        (json['quantity'] as num?)?.toInt() ??
        (json['stock'] as num?)?.toInt() ??
        (json['countInStock'] as num?)?.toInt() ??
        0;

    final ratingCount =
        (json['rating'] as num?)?.toInt() ??
        (json['ratingsQuantity'] as num?)?.toInt() ??
        0;

    // ─── Resolve Category & Subcategory Safely ───
    final rawCategory = json['category'];
    String? categoryName;
    String? categoryId = json['categoryId']?.toString();

    if (rawCategory is Map) {
      categoryName = _parseLocalized(rawCategory['name']);
      categoryId ??=
          rawCategory['_id']?.toString() ?? rawCategory['id']?.toString();
    } else if (rawCategory is String) {
      final trimmed = rawCategory.trim();
      final isHexId = isHexObjectId(trimmed);
      if (isHexId) {
        categoryId ??= trimmed;
      } else if (trimmed.isNotEmpty) {
        categoryName = trimmed;
      }
    }

    final rawSubcategory = json['subcategory'];
    String? subcategoryName;
    String? subcategoryId = json['subcategoryId']?.toString();

    if (rawSubcategory is Map) {
      subcategoryName = _parseLocalized(rawSubcategory['name']);
      subcategoryId ??=
          rawSubcategory['_id']?.toString() ?? rawSubcategory['id']?.toString();

      // If category name was not populated at root level, extract from subcategory's populated parent category
      if (categoryName == null || categoryName.isEmpty) {
        final subCatParent = rawSubcategory['category'];
        if (subCatParent is Map) {
          categoryName = _parseLocalized(subCatParent['name']);
          categoryId ??=
              subCatParent['_id']?.toString() ?? subCatParent['id']?.toString();
        } else if (subCatParent is String && categoryId == null) {
          categoryId = subCatParent;
        }
      }
    } else if (rawSubcategory is String) {
      final trimmed = rawSubcategory.trim();
      final isHexId = isHexObjectId(trimmed);
      if (isHexId) {
        subcategoryId ??= trimmed;
      } else if (trimmed.isNotEmpty) {
        subcategoryName = trimmed;
      }
    }

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
      ratingCount: ratingCount,
      category: categoryName,
      categoryId: categoryId,
      subcategory: subcategoryName,
      subcategoryId: subcategoryId,
      quantity: quantity,
      sold: (json['sold'] as num?)?.toInt() ?? 0,
      inStock: (json['inStock'] as bool?) ?? quantity > 0,
    );
  }
}
