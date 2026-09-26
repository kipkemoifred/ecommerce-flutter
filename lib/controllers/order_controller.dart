import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/order_model.dart';
import '../data/models/cart_item_model.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/app_snackbar.dart';
import '../core/services/firebase_service.dart';
import 'notification_controller.dart';
import 'product_controller.dart';

class OrderController extends GetxController {
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (FirebaseService.isFirebaseConfigured) {
      isLoading.value = true;
      _listenToFirestore();
    }
  }

  void _listenToFirestore() async {
    // 1. Immediate fetch from Firebase backend
    try {
      final initialOrders = await FirebaseService.fetchOrders();
      if (initialOrders.isNotEmpty) {
        orders.assignAll(initialOrders);
      }
    } catch (e) {
      debugPrint('[OrderController] Error during initial fetch: $e');
    } finally {
      isLoading.value = false;
    }

    // 2. Real-time stream listeners from Firebase backend
    FirebaseService.streamOrders().listen((firestoreOrders) {
      orders.assignAll(firestoreOrders);
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('[OrderController] Orders stream error: $e');
      isLoading.value = false;
    });
  }

  List<OrderModel> getCustomerOrders(String customerId) {
    return orders.where((o) => o.customerId == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<OrderModel> getSellerOrders(String sellerId) {
    return orders.where((o) {
      return o.items.any((item) => item.product.sellerId == sellerId);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  OrderModel? getOrderById(String orderId) {
    return orders.firstWhereOrNull((o) => o.id == orderId);
  }

  Future<OrderModel> placeOrder({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required List<CartItemModel> items,
    required double subtotal,
    required double shippingFee,
    required double tax,
    required double discount,
    required double totalAmount,
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 700));

    final orderId = 'ORD-${const Uuid().v4().substring(0, 6).toUpperCase()}';
    final trackingNumber = 'TRK-US-${const Uuid().v4().substring(0, 8).toUpperCase()}';

    final now = DateTime.now();
    final newOrder = OrderModel(
      id: orderId,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      items: List.from(items),
      subtotal: subtotal,
      shippingFee: shippingFee,
      tax: tax,
      discount: discount,
      totalAmount: totalAmount,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      status: AppConstants.orderConfirmed,
      trackingNumber: trackingNumber,
      createdAt: now,
      updatedAt: now,
      timeline: [
        OrderTrackingStep(
          title: 'Order Placed',
          description: 'Payment authorized via $paymentMethod.',
          timestamp: now,
          isCompleted: true,
        ),
        OrderTrackingStep(
          title: 'Order Confirmed',
          description: 'Order confirmed and routed to fulfillment warehouse.',
          timestamp: now,
          isCompleted: true,
        ),
        OrderTrackingStep(
          title: 'Shipped',
          description: 'Package en route to sorting hub.',
          timestamp: now.add(const Duration(hours: 12)),
          isCompleted: false,
        ),
        OrderTrackingStep(
          title: 'Out for Delivery',
          description: 'Courier out for delivery to $shippingAddress.',
          timestamp: now.add(const Duration(days: 1)),
          isCompleted: false,
        ),
        OrderTrackingStep(
          title: 'Delivered',
          description: 'Package delivered.',
          timestamp: now.add(const Duration(days: 2)),
          isCompleted: false,
        ),
      ],
    );

    orders.insert(0, newOrder);
    FirebaseService.saveOrder(newOrder);

    // Deduct inventory stock in real-time
    try {
      final productController = Get.find<ProductController>();
      for (final item in items) {
        final currentStock = item.product.stock;
        final newStock = (currentStock - item.quantity).clamp(0, 999999);
        productController.updateStock(item.product.id, newStock);
      }
    } catch (_) {}

    // Notify user
    try {
      final notifController = Get.find<NotificationController>();
      notifController.addNotification(
        userId: customerId,
        title: 'Order Confirmed! 📦',
        message: 'Order #$orderId has been placed successfully for \$${totalAmount.toStringAsFixed(2)}.',
        type: 'order',
        relatedId: orderId,
      );
    } catch (_) {}

    isLoading.value = false;
    return newOrder;
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = orders[index];
      final updatedTimeline = List<OrderTrackingStep>.from(order.timeline);

      // Update timeline step completions based on status
      for (int i = 0; i < updatedTimeline.length; i++) {
        final step = updatedTimeline[i];
        if (newStatus == AppConstants.orderDelivered) {
          updatedTimeline[i] = OrderTrackingStep(
            title: step.title,
            description: step.description,
            timestamp: step.timestamp,
            isCompleted: true,
          );
        } else if (newStatus == AppConstants.orderShipped &&
            (step.title == 'Order Placed' || step.title == 'Order Confirmed' || step.title == 'Shipped')) {
          updatedTimeline[i] = OrderTrackingStep(
            title: step.title,
            description: step.description,
            timestamp: step.timestamp,
            isCompleted: true,
          );
        }
      }

      orders[index] = order.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        timeline: updatedTimeline,
      );
      FirebaseService.updateOrderStatus(orderId, newStatus);

      // Trigger notification
      try {
        final notifController = Get.find<NotificationController>();
        notifController.addNotification(
          userId: order.customerId,
          title: 'Order Status Update 🔔',
          message: 'Order #${order.id} status is now "$newStatus".',
          type: 'order',
          relatedId: order.id,
        );
      } catch (_) {}

      AppSnackbar.show(
        'Status Updated',
        'Order #${order.id} marked as $newStatus',
        backgroundColor: Colors.blue.shade50,
      );
    }
  }

  void cancelOrder(String orderId) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = orders[index];
      orders[index] = order.copyWith(
        status: AppConstants.orderCancelled,
        updatedAt: DateTime.now(),
      );
      FirebaseService.updateOrderStatus(orderId, AppConstants.orderCancelled);

      AppSnackbar.show(
        'Order Cancelled',
        'Order #$orderId has been cancelled.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
    }
  }
}
