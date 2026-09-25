class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'customer', 'seller', 'admin'
  final String avatarUrl;
  final String phone;
  final String address;
  final String storeName;
  final String storeDescription;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final double totalSpent;
  final int totalOrders;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    this.phone = '+1 (555) 234-5678',
    this.address = '742 Evergreen Terrace, Springfield, OR',
    this.storeName = '',
    this.storeDescription = '',
    this.isVerified = false,
    this.isActive = true,
    DateTime? createdAt,
    this.totalSpent = 0.0,
    this.totalOrders = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isCustomer => role == 'customer';
  bool get isSeller => role == 'seller';
  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    String? phone,
    String? address,
    String? storeName,
    String? storeDescription,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    double? totalSpent,
    int? totalOrders,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      storeName: storeName ?? this.storeName,
      storeDescription: storeDescription ?? this.storeDescription,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      totalSpent: totalSpent ?? this.totalSpent,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'address': address,
      'storeName': storeName,
      'storeDescription': storeDescription,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'totalSpent': totalSpent,
      'totalOrders': totalOrders,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      avatarUrl: map['avatarUrl'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
      phone: map['phone'] ?? '+1 (555) 234-5678',
      address: map['address'] ?? '742 Evergreen Terrace, Springfield, OR',
      storeName: map['storeName'] ?? '',
      storeDescription: map['storeDescription'] ?? '',
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
    );
  }
}
