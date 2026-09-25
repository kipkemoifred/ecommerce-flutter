import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecommerce/controllers/auth_controller.dart';
import 'package:ecommerce/controllers/product_controller.dart';
import 'package:ecommerce/controllers/cart_controller.dart';
import 'package:ecommerce/controllers/wishlist_controller.dart';
import 'package:ecommerce/controllers/order_controller.dart';
import 'package:ecommerce/controllers/review_controller.dart';
import 'package:ecommerce/controllers/notification_controller.dart';
import 'package:ecommerce/core/constants/app_constants.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put(NotificationController());
    Get.put(AuthController());
    Get.put(ProductController());
    Get.put(CartController());
    Get.put(WishlistController());
    Get.put(OrderController());
    Get.put(ReviewController());
  });

  test('ShopNest marketplace controllers and business logic unit test', () async {
    final productController = Get.find<ProductController>();
    final cartController = Get.find<CartController>();
    final wishlistController = Get.find<WishlistController>();
    final authController = Get.find<AuthController>();
    final orderController = Get.find<OrderController>();
    final reviewController = Get.find<ReviewController>();
    final notifController = Get.find<NotificationController>();

    // 1. Verify Catalog
    expect(productController.products.isNotEmpty, isTrue);
    expect(productController.categories.isNotEmpty, isTrue);

    // 2. Customer Auth & Demo Roles
    expect(authController.currentUser.value?.role, equals(AppConstants.roleCustomer));

    // 3. Cart Operations
    final testProduct = productController.products.first;
    cartController.addToCart(testProduct, quantity: 2);
    expect(cartController.itemCount, equals(2));
    expect(cartController.subtotal, equals(testProduct.price * 2));

    // Promo code test
    final promoApplied = cartController.applyPromoCode('SOUND20');
    expect(promoApplied, isTrue);
    expect(cartController.discountPercentage.value, equals(20.0));
    expect(cartController.discountAmount, equals(cartController.subtotal * 0.20));

    // 4. Wishlist Operations
    wishlistController.toggleWishlist(testProduct);
    expect(wishlistController.isInWishlist(testProduct.id), isTrue);

    // 5. Order Placement
    final order = await orderController.placeOrder(
      customerId: 'user_cust_1',
      customerName: 'Sarah Connor',
      customerEmail: 'sarah@example.com',
      items: cartController.items,
      subtotal: cartController.subtotal,
      shippingFee: cartController.shippingFee,
      tax: cartController.taxAmount,
      discount: cartController.discountAmount,
      totalAmount: cartController.totalAmount,
      shippingAddress: '123 Main St, New York, NY',
      paymentMethod: 'Credit Card',
    );
    expect(order.id.startsWith('ORD-'), isTrue);
    expect(order.timeline.length, equals(5));

    // 6. Order Status Transition
    orderController.updateOrderStatus(order.id, AppConstants.orderShipped);
    final updatedOrder = orderController.getOrderById(order.id);
    expect(updatedOrder?.status, equals(AppConstants.orderShipped));

    // 7. Reviews
    reviewController.addReview(
      productId: testProduct.id,
      userId: 'user_cust_1',
      userName: 'Sarah',
      rating: 5.0,
      comment: 'Top quality product!',
    );
    expect(reviewController.getReviewsForProduct(testProduct.id).isNotEmpty, isTrue);

    // 8. Notifications
    final notifs = notifController.getUserNotifications('user_cust_1');
    expect(notifs.isNotEmpty, isTrue);

    // 9. Role Switching (Customer -> Seller -> Admin)
    authController.switchDemoRole(AppConstants.roleSeller);
    expect(authController.isSeller, isTrue);

    authController.switchDemoRole(AppConstants.roleAdmin);
    expect(authController.isAdmin, isTrue);
  });
}
