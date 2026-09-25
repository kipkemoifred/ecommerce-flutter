import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../data/models/order_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../customer/order_tracking_screen.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  void _showOverrideDialog(BuildContext context, OrderModel order, AdminController controller) {
    String selectedStatus = order.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Admin Status Override: #${order.id}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppConstants.orderPending,
                  AppConstants.orderConfirmed,
                  AppConstants.orderShipped,
                  AppConstants.orderDelivered,
                  AppConstants.orderCancelled,
                ].map((s) {
                  final isSel = selectedStatus == s;
                  return InkWell(
                    onTap: () => setState(() => selectedStatus = s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isSel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSel ? AppColors.adminBadge : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(s, style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    controller.overrideOrderStatus(order.id, selectedStatus);
                    Get.back();
                  },
                  child: const Text('Save Override'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Marketplace Orders'),
      ),
      body: Obx(() {
        final orders = adminController.allOrders;

        if (orders.isEmpty) {
          return const Center(child: Text('No orders placed on platform.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final o = orders[index];

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${o.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(o.status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          o.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(o.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Customer: ${o.customerName} • ${o.customerEmail}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text('Placed: ${CurrencyFormatter.formatDate(o.createdAt)}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${CurrencyFormatter.format(o.totalAmount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => Get.to(() => OrderTrackingScreen(order: o)),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(70, 34),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: const Text('View', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _showOverrideDialog(context, o, adminController),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.adminBadge,
                              minimumSize: const Size(80, 34),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: const Text('Override', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
