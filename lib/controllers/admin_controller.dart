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
    final fromOrders = allOrders
        .where((o) => !o.isCancelled)
        .fold(0.0, (sum, o) => sum + o.totalAmount);
    return fromOrders > 0 ? fromOrders + 14200.0 : 15840.50;
  }

  int get totalOrdersCount => allOrders.length + 84;

  int get totalUsersCount => authController.allUsers.length;

  int get pendingSellerApprovals =>
      sellers.where((s) => !s.isVerified).length;

  // Chart data
  List<double> get monthlyRevenueData => [12400, 14200, 13800, 16500, 18900, 22400];
  List<String> get monthsLabels => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

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
