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

  List<ProductModel> get myProducts =>
      productController.getProductsBySeller(sellerId);

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
    // If demo has newly started, provide baseline sales
    return total > 0 ? total : 2840.50;
  }

  int get totalCompletedOrders =>
      myOrders.where((o) => o.isDelivered).length;

  int get pendingOrdersCount =>
      myOrders.where((o) => o.isActive).length;

  // Monthly sales for charts
  List<double> get weeklySalesData => [450.0, 720.0, 600.0, 890.0, 1100.0, 950.0, 1280.0];
  List<String> get weeklySalesDays => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}
