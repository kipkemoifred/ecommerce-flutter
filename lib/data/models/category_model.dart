class CategoryModel {
  final String id;
  final String name;
  final String icon; // Icon name or unicode or image
  final String imageUrl;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    this.productCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'productCount': productCount,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'category',
      imageUrl: map['imageUrl'] ?? '',
      productCount: map['productCount'] ?? 0,
    );
  }
}
