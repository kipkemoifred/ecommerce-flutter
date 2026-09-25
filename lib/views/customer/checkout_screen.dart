import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController(text: 'New York');
  final _zipController = TextEditingController(text: '10001');

  String _selectedPaymentMethod = 'Credit Card';
  String _selectedShippingMethod = 'Standard';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;
    if (user != null) {
      _addressController.text = user.address;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  double get _additionalExpressFee => _selectedShippingMethod == 'Express' ? 9.99 : 0.0;

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = Get.find<CartController>();
    if (cart.items.isEmpty) {
      Get.snackbar('Cart Empty', 'Please add items before checking out.');
      return;
    }

    setState(() => _isProcessing = true);

    final auth = Get.find<AuthController>();
    final orderController = Get.find<OrderController>();
    final user = auth.currentUser.value;

    final fullAddress = '${_addressController.text}, ${_cityController.text}, ${_zipController.text}';
    final finalShipping = cart.shippingFee + _additionalExpressFee;
    final finalTotal = cart.totalAmount + _additionalExpressFee;

    final order = await orderController.placeOrder(
      customerId: user?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
      customerName: user?.name ?? 'Guest Shopper',
      customerEmail: user?.email ?? 'guest@example.com',
      items: cart.items,
      subtotal: cart.subtotal,
      shippingFee: finalShipping,
      tax: cart.taxAmount,
      discount: cart.discountAmount,
      totalAmount: finalTotal,
      shippingAddress: fullAddress,
      paymentMethod: _selectedPaymentMethod,
    );

    // Clear shopping cart
    cart.clearCart();
    setState(() => _isProcessing = false);

    // Navigate to Order Tracking
    Get.off(() => OrderTrackingScreen(order: order, isNewOrder: true));
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Shipping Address Section
              _buildSectionCard(
                title: '1. Shipping Address',
                icon: Icons.location_on_outlined,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _addressController,
                      label: 'Street Address',
                      hintText: '123 Main St, Apt 4B',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _cityController,
                            label: 'City',
                            hintText: 'City',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _zipController,
                            label: 'Postal / ZIP Code',
                            hintText: '10001',
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Contact Phone Number',
                      hintText: '+1 (555) 000-0000',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Delivery Options Section
              _buildSectionCard(
                title: '2. Delivery Option',
                icon: Icons.local_shipping_outlined,
                child: Column(
                  children: [
                    _buildDeliveryOption(
                      'Standard',
                      'Standard Delivery (3-5 days)',
                      cart.shippingFee == 0 ? 'FREE' : CurrencyFormatter.format(cart.shippingFee),
                    ),
                    const SizedBox(height: 8),
                    _buildDeliveryOption(
                      'Express',
                      'Express Overnight Delivery (1-2 days)',
                      '\$9.99',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Payment Method Section
              _buildSectionCard(
                title: '3. Payment Method',
                icon: Icons.payment_outlined,
                child: Column(
                  children: [
                    _buildPaymentOption('Credit Card', 'Visa / Mastercard / Amex', Icons.credit_card),
                    const SizedBox(height: 8),
                    _buildPaymentOption('Apple Pay / Google Pay', 'Instant one-touch checkout', Icons.apple),
                    const SizedBox(height: 8),
                    _buildPaymentOption('Cash on Delivery', 'Pay when receiving package', Icons.money),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Order Review
              _buildSectionCard(
                title: '4. Order Summary',
                icon: Icons.receipt_long_outlined,
                child: Obx(() {
                  final total = cart.totalAmount + _additionalExpressFee;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Items Subtotal:'),
                          Text(CurrencyFormatter.format(cart.subtotal)),
                        ],
                      ),
                      if (cart.discountAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Discount:', style: TextStyle(color: Colors.green)),
                            Text('-${CurrencyFormatter.format(cart.discountAmount)}', style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Shipping:'),
                          Text(CurrencyFormatter.format(cart.shippingFee + _additionalExpressFee)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax (8%):'),
                          Text(CurrencyFormatter.format(cart.taxAmount)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            CurrencyFormatter.format(total),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Place Order CTA
              CustomButton(
                text: 'Place Order (${CurrencyFormatter.format(cart.totalAmount + _additionalExpressFee)})',
                isLoading: _isProcessing,
                onPressed: _handlePlaceOrder,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildDeliveryOption(String value, String label, String price) {
    final isSelected = _selectedShippingMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedShippingMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon) {
    final isSelected = _selectedPaymentMethod == title;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = title),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
