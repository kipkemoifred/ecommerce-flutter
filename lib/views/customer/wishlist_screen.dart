import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wishlist_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../core/constants/app_colors.dart';
import '../common/custom_button.dart';
import '../common/product_card.dart';
import 'search_filter_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        actions: [
          Obx(() {
            if (wishlistController.wishlist.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: () {
                for (var p in List.from(wishlistController.wishlist)) {
                  wishlistController.moveToCart(p, cartController);
                }
                Get.snackbar('Moved to Cart', 'All wishlist items moved to your shopping cart.');
              },
              child: const Text('Move All to Cart'),
            );
          }),
        ],
      ),
      body: Obx(() {
        final items = wishlistController.wishlist;

        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Wishlist is Empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Save your favorite items here to purchase later or track discounts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: CustomButton(
                      text: 'Discover Products',
                      onPressed: () => Get.to(() => const SearchFilterScreen()),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.58,
          ),
          itemBuilder: (context, index) {
            return ProductCard(product: items[index]);
          },
        );
      }),
    );
  }
}
