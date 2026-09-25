import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/product_model.dart';
import '../core/utils/app_snackbar.dart';
import 'cart_controller.dart';

class WishlistController extends GetxController {
  final RxList<ProductModel> wishlist = <ProductModel>[].obs;

  bool isInWishlist(String productId) {
    return wishlist.any((p) => p.id == productId);
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      wishlist.removeWhere((p) => p.id == product.id);
      AppSnackbar.show(
        'Removed from Wishlist',
        '${product.title} removed from your saved items.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      wishlist.add(product);
      AppSnackbar.show(
        'Added to Wishlist',
        '${product.title} saved to your wishlist ❤️',
        backgroundColor: Colors.pink.shade50,
        colorText: Colors.pink.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void moveToCart(ProductModel product, CartController cartController) {
    cartController.addToCart(product);
    wishlist.removeWhere((p) => p.id == product.id);
  }

  void clearWishlist() {
    wishlist.clear();
  }
}
