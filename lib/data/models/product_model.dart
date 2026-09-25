class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final String category;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final int stock;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isApproved;
  final DateTime createdAt;
  final List<String> tags;
  final List<String> colors;
  final List<String> sizes;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    required this.stock,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.isFeatured = false,
    this.isApproved = true,
    DateTime? createdAt,
    this.tags = const [],
    this.colors = const [],
    this.sizes = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isInStock => stock > 0;
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent => hasDiscount
      ? (((originalPrice! - price) / originalPrice!) * 100).round()
      : 0;

  String get mainImage =>
      images.isNotEmpty ? images.first : 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=500&q=80';

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    String? category,
    List<String>? images,
    String? sellerId,
    String? sellerName,
    int? stock,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isApproved,
    DateTime? createdAt,
    List<String>? tags,
    List<String>? colors,
    List<String>? sizes,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      images: images ?? this.images,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'category': category,
      'images': images,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'colors': colors,
      'sizes': sizes,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      category: map['category'] ?? 'General',
      images: List<String>.from(map['images'] ?? []),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? 'Official Store',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      isApproved: map['isApproved'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
      colors: List<String>.from(map['colors'] ?? []),
      sizes: List<String>.from(map['sizes'] ?? []),
    );
  }
}
