import 'package:get/get.dart';
import 'product_controller.dart';
import 'order_controller.dart';
import 'auth_controller.dart';
import '../data/models/product_model.dart';
import '../data/models/order_model.dart';

class SellerController extends GetxController {
  final ProductController productController = Get.find<ProductController>();
  final OrderController orderController = Get.find<OrderController>();
  final AuthController authController = Get.find<AuthController>();

  String get sellerId => authController.currentUser.value?.id ?? 'user_sell_1';

  List<ProductModel> get myProducts {
    final currentId = sellerId;
    return productController.products.where((p) {
      if (p.sellerId == currentId) return true;
      if (currentId == 'user_sell_1' && (p.sellerId.isEmpty || p.sellerId == 'user_sell_1')) return true;
      if (authController.currentUser.value != null && p.sellerId == authController.currentUser.value!.id) return true;
      return false;
    }).toList();
  }

  List<OrderModel> get myOrders =>
      orderController.getSellerOrders(sellerId);

  int get activeProductsCount => myProducts.where((p) => p.isInStock).length;

  int get lowStockProductsCount => myProducts.where((p) => p.stock < 10).length;

  double get totalRevenue {
    double total = 0.0;
    for (var order in myOrders) {
      if (!order.isCancelled) {
        for (var item in order.items) {
          if (item.product.sellerId == sellerId) {
            total += item.totalPrice;
          }
        }
      }
    }
    return total;
  }

  int get totalCompletedOrders =>
      myOrders.where((o) => o.isDelivered).length;

  int get pendingOrdersCount =>
      myOrders.where((o) => o.isActive).length;

  // Real weekly sales computed from live orders
  List<double> get weeklySalesData {
    final days = List.filled(7, 0.0);
    final now = DateTime.now();
    for (var order in myOrders) {
      if (!order.isCancelled) {
        final diff = now.difference(order.createdAt).inDays;
        if (diff >= 0 && diff < 7) {
          final idx = 6 - diff;
          for (var item in order.items) {
            if (item.product.sellerId == sellerId) {
              days[idx] += item.totalPrice;
            }
          }
        }
      }
    }
    return days;
  }
  List<String> get weeklySalesDays => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}
