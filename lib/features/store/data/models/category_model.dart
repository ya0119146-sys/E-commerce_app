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

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      slug: json['slug'] as String?,
    );
  }
}
