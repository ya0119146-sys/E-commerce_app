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

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'];
    String cid = '';
    String cname = '';

    if (categoryData is Map) {
      cid = categoryData['_id'] as String? ?? categoryData['id'] as String? ?? '';
      cname = categoryData['name'] as String? ?? '';
    } else if (categoryData is String) {
      cid = categoryData;
    }

    return SubCategoryModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
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
