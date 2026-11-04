import '../../../../core/localization/locale_cubit.dart';

/// SubCategory model for the catalog.
class SubCategoryModel {
  final String id;
  final String name;
  final String? image;
  final String categoryId;
  final String categoryName;

  const SubCategoryModel({
    required this.id,
    required this.name,
    this.image,
    required this.categoryId,
    required this.categoryName,
  });

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

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'];
    String cid = '';
    String cname = '';

    if (categoryData is Map) {
      cid =
          categoryData['_id'] as String? ?? categoryData['id'] as String? ?? '';
      cname = _parseLocalized(categoryData['name']);
    } else if (categoryData is String) {
      cid = categoryData;
    }

    return SubCategoryModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: _parseLocalized(json['name']),
      image: json['image'] as String?,
      categoryId: cid,
      categoryName: cname,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (image != null) 'image': image,
    'category': categoryId,
  };
}
