import 'cart_item_model.dart';
import '../../core/constants/app_constants.dart';

class OrderTrackingStep {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  OrderTrackingStep({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory OrderTrackingStep.fromMap(Map<String, dynamic> map) {
    return OrderTrackingStep(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final List<CartItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double tax;
  final double discount;
  final double totalAmount;
  final String shippingAddress;
  final String paymentMethod;
  final String status;
  final String trackingNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderTrackingStep> timeline;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.tax,
    this.discount = 0.0,
    required this.totalAmount,
    required this.shippingAddress,
    required this.paymentMethod,
    this.status = AppConstants.orderPending,
    required this.trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderTrackingStep>? timeline,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        timeline = timeline ?? [];

  bool get isDelivered => status == AppConstants.orderDelivered;
  bool get isCancelled => status == AppConstants.orderCancelled;
  bool get isActive => !isDelivered && !isCancelled;

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    List<CartItemModel>? items,
    double? subtotal,
    double? shippingFee,
    double? tax,
    double? discount,
    double? totalAmount,
    String? shippingAddress,
    String? paymentMethod,
    String? status,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderTrackingStep>? timeline,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      timeline: timeline ?? this.timeline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'tax': tax,
      'discount': discount,
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'status': status,
      'trackingNumber': trackingNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'timeline': timeline.map((t) => t.toMap()).toList(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromMap(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (map['shippingFee'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: map['shippingAddress'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Credit Card',
      status: map['status'] ?? AppConstants.orderPending,
      trackingNumber: map['trackingNumber'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      timeline: (map['timeline'] as List<dynamic>?)
              ?.map((step) => OrderTrackingStep.fromMap(Map<String, dynamic>.from(step)))
              .toList() ??
          [],
    );
  }
}
