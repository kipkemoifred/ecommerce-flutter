import 'package:get/get.dart';
import 'product_controller.dart';
import 'order_controller.dart';
import 'auth_controller.dart';
import '../data/models/user_model.dart';
import '../data/models/product_model.dart';
import '../data/models/order_model.dart';

class AdminController extends GetxController {
  final ProductController productController = Get.find<ProductController>();
  final OrderController orderController = Get.find<OrderController>();
  final AuthController authController = Get.find<AuthController>();

  List<UserModel> get customers =>
      authController.allUsers.where((u) => u.isCustomer).toList();

  List<UserModel> get sellers =>
      authController.allUsers.where((u) => u.isSeller).toList();

  List<ProductModel> get allProducts => productController.products;

  List<OrderModel> get allOrders => orderController.orders;

  double get totalMarketplaceRevenue {
    return allOrders
        .where((o) => !o.isCancelled)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  int get totalOrdersCount => allOrders.length;

  int get totalUsersCount => authController.allUsers.length;

  int get pendingSellerApprovals =>
      sellers.where((s) => !s.isVerified).length;

  // Chart data computed from real orders
  List<double> get monthlyRevenueData {
    final totals = List.filled(6, 0.0);
    final now = DateTime.now();
    for (final order in allOrders) {
      if (!order.isCancelled) {
        final monthDiff = (now.year - order.createdAt.year) * 12 + now.month - order.createdAt.month;
        if (monthDiff >= 0 && monthDiff < 6) {
          final idx = 5 - monthDiff;
          totals[idx] += order.totalAmount;
        }
      }
    }
    return totals;
  }
  List<String> get monthsLabels {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = ((now.month - 1 - (5 - i)) % 12 + 12) % 12;
      return names[month];
    });
  }

  void toggleUserStatus(String userId) {
    authController.toggleUserStatus(userId);
  }

  void verifySeller(String sellerId) {
    authController.verifySeller(sellerId);
  }

  void toggleProductApproval(String productId) {
    productController.toggleApproved(productId);
  }

  void toggleProductFeatured(String productId) {
    productController.toggleFeatured(productId);
  }

  void overrideOrderStatus(String orderId, String newStatus) {
    orderController.updateOrderStatus(orderId, newStatus);
  }
}
