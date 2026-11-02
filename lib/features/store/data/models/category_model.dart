import '../../../../core/localization/locale_cubit.dart';

/// Category model for the catalog.
class CategoryModel {
  final String id;
  final String name;
  final String? image;
  final String? slug;

  const CategoryModel({
    required this.id,
    required this.name,
    this.image,
    this.slug,
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

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: _parseLocalized(json['name']),
      image: json['image'] as String?,
      slug: json['slug'] as String?,
    );
  }
}
