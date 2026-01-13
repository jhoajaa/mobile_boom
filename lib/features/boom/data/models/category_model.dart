class CategoryModel {
  final String categoryId;
  final String categoryName;

  CategoryModel({required this.categoryId, required this.categoryName});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
    );
  }
}