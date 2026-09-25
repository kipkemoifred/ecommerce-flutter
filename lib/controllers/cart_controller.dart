import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/app_snackbar.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> items = <CartItemModel>[].obs;
  final RxString promoCode = ''.obs;
  final RxDouble discountPercentage = 0.0.obs;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => subtotal * (discountPercentage.value / 100);

  double get shippingFee {
    if (items.isEmpty) return 0.0;
    return subtotal >= AppConstants.freeShippingThreshold
        ? 0.0
        : AppConstants.standardShippingFee;
  }

  double get taxAmount => (subtotal - discountAmount) * AppConstants.taxRate;

  double get totalAmount {
    if (items.isEmpty) return 0.0;
    return (subtotal - discountAmount) + shippingFee + taxAmount;
  }

  void addToCart(
    ProductModel product, {
    int quantity = 1,
    String? selectedColor,
    String? selectedSize,
  }) {
    final existingIndex = items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedColor == selectedColor &&
          item.selectedSize == selectedSize,
    );

    if (existingIndex != -1) {
      items[existingIndex].quantity += quantity;
      items.refresh();
    } else {
      items.add(
        CartItemModel(
          product: product,
          quantity: quantity,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
        ),
      );
    }

    AppSnackbar.show(
      'Added to Cart',
      '${product.title} has been added to your shopping cart.',
      backgroundColor: Colors.indigo.shade50,
      colorText: Colors.indigo.shade900,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void incrementQuantity(int index) {
    if (index >= 0 && index < items.length) {
      if (items[index].quantity < items[index].product.stock) {
        items[index].quantity++;
        items.refresh();
      } else {
        AppSnackbar.show('Stock Limit', 'Only ${items[index].product.stock} units available in inventory.');
      }
    }
  }

  void decrementQuantity(int index) {
    if (index >= 0 && index < items.length) {
      if (items[index].quantity > 1) {
        items[index].quantity--;
        items.refresh();
      } else {
        removeItem(index);
      }
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < items.length) {
      final removed = items.removeAt(index);
      AppSnackbar.show(
        'Item Removed',
        '${removed.product.title} removed from cart.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool applyPromoCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'SOUND20' || cleanCode == 'SAVE20') {
      promoCode.value = cleanCode;
      discountPercentage.value = 20.0;
      AppSnackbar.show(
        'Promo Applied!',
        '20% discount has been applied to your cart!',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );
      return true;
    } else if (cleanCode == 'WELCOME10') {
      promoCode.value = cleanCode;
      discountPercentage.value = 10.0;
      AppSnackbar.show('Promo Applied!', '10% discount applied!');
      return true;
    } else {
      AppSnackbar.show('Invalid Promo', 'Code "$code" is invalid or expired.');
      return false;
    }
  }

  void removePromo() {
    promoCode.value = '';
    discountPercentage.value = 0.0;
  }

  void clearCart() {
    items.clear();
    promoCode.value = '';
    discountPercentage.value = 0.0;
  }
}
