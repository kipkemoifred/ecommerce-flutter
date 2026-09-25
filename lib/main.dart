import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/storage_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/api_service.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/wishlist_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/review_controller.dart';
import 'controllers/notification_controller.dart';
import 'views/customer/customer_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system overlay styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize core services safely
  await StorageService.init();
  await FirebaseService.init();
  ApiService.init();

  // Initialize GetX global controllers
  Get.put(NotificationController());
  Get.put(AuthController());
  Get.put(ProductController());
  Get.put(CartController());
  Get.put(WishlistController());
  Get.put(OrderController());
  Get.put(ReviewController());

  runApp(const ShopNestApp());
}

class ShopNestApp extends StatelessWidget {
  const ShopNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      defaultTransition: Transition.cupertino,
      home: const CustomerMainScreen(),
    );
  }
}
