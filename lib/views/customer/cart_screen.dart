import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../common/custom_button.dart';
import 'checkout_screen.dart';
import 'search_filter_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Obx(() {
            if (cartController.items.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Clear Cart',
                  middleText: 'Are you sure you want to remove all items from your cart?',
                  textConfirm: 'Clear All',
                  textCancel: 'Cancel',
                  confirmTextColor: Colors.white,
                  buttonColor: AppColors.error,
                  onConfirm: () {
                    cartController.clearCart();
                    Get.back();
                  },
                );
              },
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (cartController.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Cart is Empty',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Looks like you haven\'t added any items to your shopping cart yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: CustomButton(
                      text: 'Start Shopping',
                      onPressed: () => Get.to(() => const SearchFilterScreen()),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Free Shipping Progress Bar
            _buildFreeShippingTracker(cartController),

            // Cart Items List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cartController.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = cartController.items[index];

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Product Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 75,
                            height: 75,
                            child: Image.network(
                              item.product.mainImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Item Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (item.selectedColor != null)
                                    Text(
                                      '${item.selectedColor} • ',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  if (item.selectedSize != null)
                                    Text(
                                      '${item.selectedSize}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                CurrencyFormatter.format(item.product.price),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quantity Stepper
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: () => cartController.decrementQuantity(index),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () => cartController.incrementQuantity(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Order Summary & Checkout Bottom Sheet
            _buildCheckoutSection(context, cartController),
          ],
        );
      }),
    );
  }

  Widget _buildFreeShippingTracker(CartController controller) {
    final subtotal = controller.subtotal;
    final threshold = AppConstants.freeShippingThreshold;
    final progress = (subtotal / threshold).clamp(0.0, 1.0);
    final remaining = threshold - subtotal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                remaining <= 0
                    ? '🎉 You unlocked FREE Shipping!'
                    : 'Add \$${remaining.toStringAsFixed(2)} more for FREE Shipping',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Promo Code Input
            if (controller.promoCode.isEmpty)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _promoController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Enter Promo Code (e.g. SOUND20)',
                          hintStyle: const TextStyle(fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_promoController.text.trim().isNotEmpty) {
                        final ok = controller.applyPromoCode(_promoController.text);
                        if (ok) _promoController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(80, 44),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.discount, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Promo ${controller.promoCode.value} Applied (-${controller.discountPercentage.value.toInt()}%)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.green),
                      onPressed: controller.removePromo,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Cost summary rows
            _buildCostRow('Subtotal', CurrencyFormatter.format(controller.subtotal)),
            if (controller.discountAmount > 0)
              _buildCostRow(
                'Discount',
                '-${CurrencyFormatter.format(controller.discountAmount)}',
                textColor: Colors.green,
              ),
            _buildCostRow(
              'Shipping',
              controller.shippingFee == 0 ? 'FREE' : CurrencyFormatter.format(controller.shippingFee),
              textColor: controller.shippingFee == 0 ? Colors.green : AppColors.textPrimary,
            ),
            _buildCostRow('Estimated Tax', CurrencyFormatter.format(controller.taxAmount)),
            const Divider(height: 16),
            _buildCostRow(
              'Total Amount',
              CurrencyFormatter.format(controller.totalAmount),
              isTotal: true,
            ),
            const SizedBox(height: 16),

            // Checkout Button
            CustomButton(
              text: 'Proceed to Checkout (${controller.itemCount} items)',
              onPressed: () => Get.to(() => const CheckoutScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String title, String value, {bool isTotal = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: textColor ?? (isTotal ? AppColors.primaryDark : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
