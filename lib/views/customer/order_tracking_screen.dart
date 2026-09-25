import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/models/order_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../controllers/order_controller.dart';
import '../common/custom_button.dart';
import 'customer_main_screen.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;
  final bool isNewOrder;

  const OrderTrackingScreen({
    super.key,
    required this.order,
    this.isNewOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isNewOrder) {
              Get.offAll(() => const CustomerMainScreen(initialIndex: 4));
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: Obx(() {
        final liveOrder = orderController.getOrderById(order.id) ?? order;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // New Order Celebration Banner
              if (isNewOrder) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Placed Successfully!',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Confirmation has been sent to ${liveOrder.customerEmail}',
                              style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Tracking Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tracking Number', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              liveOrder.trackingNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: liveOrder.trackingNumber));
                            Get.snackbar('Copied', 'Tracking number copied to clipboard.');
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Status', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(liveOrder.status).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                liveOrder.status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _getStatusColor(liveOrder.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Order Date', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.formatDateShort(liveOrder.createdAt),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tracking Timeline
              const Text(
                'Delivery Timeline',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: liveOrder.timeline.length,
                  itemBuilder: (context, index) {
                    final step = liveOrder.timeline[index];
                    final isLast = index == liveOrder.timeline.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step Indicator & Line
                          Column(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: step.isCompleted
                                      ? AppColors.secondary
                                      : Colors.grey.shade300,
                                ),
                                child: Icon(
                                  step.isCompleted ? Icons.check : Icons.circle,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: step.isCompleted
                                        ? AppColors.secondary
                                        : Colors.grey.shade300,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),

                          // Step Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        step.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: step.isCompleted
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.formatDateShort(step.timestamp),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: step.isCompleted
                                              ? AppColors.textSecondary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: step.isCompleted
                                          ? AppColors.textSecondary
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Ordered Items Card
              const Text(
                'Items in this Order',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: liveOrder.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final item = liveOrder.items[index];
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.network(
                              item.product.mainImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                'Qty: ${item.quantity} • ${CurrencyFormatter.format(item.product.price)}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(item.totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Shipping Address Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delivery Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(liveOrder.shippingAddress, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cancel Order Button (if eligible)
              if (liveOrder.isActive) ...[
                CustomButton(
                  text: 'Cancel Order',
                  backgroundColor: AppColors.error,
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Cancel Order',
                      middleText: 'Are you sure you want to cancel order #${liveOrder.id}?',
                      textConfirm: 'Yes, Cancel',
                      textCancel: 'Keep Order',
                      confirmTextColor: Colors.white,
                      buttonColor: AppColors.error,
                      onConfirm: () {
                        orderController.cancelOrder(liveOrder.id);
                        Get.back();
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],

              // Back to Shopping
              CustomButton(
                text: 'Back to Marketplace',
                isOutlined: true,
                onPressed: () => Get.offAll(() => const CustomerMainScreen()),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Shipped':
      case 'Out for Delivery':
        return Colors.blue;
      default:
        return Colors.amber.shade800;
    }
  }
}
