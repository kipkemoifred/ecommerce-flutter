import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import 'order_tracking_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifController = Get.find<NotificationController>();
    final auth = Get.find<AuthController>();
    final orderController = Get.find<OrderController>();
    final userId = auth.currentUser.value?.id ?? 'user_cust_1';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => notifController.markAllAsRead(userId),
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: Obx(() {
        final notifications = notifController.getUserNotifications(userId);

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'No notifications yet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text(
                  'We\'ll notify you when orders or promotions arrive.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notif = notifications[index];

            return InkWell(
              onTap: () {
                notifController.markAsRead(notif.id);
                if (notif.relatedId != null) {
                  final order = orderController.getOrderById(notif.relatedId!);
                  if (order != null) {
                    Get.to(() => OrderTrackingScreen(order: order));
                  }
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: notif.isRead ? Colors.white : AppColors.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: notif.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getTypeColor(notif.type).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getTypeIcon(notif.type), color: _getTypeColor(notif.type), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (!notif.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notif.message,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyFormatter.formatDate(notif.timestamp),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.local_shipping_outlined;
      case 'promo':
        return Icons.discount_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'order':
        return AppColors.primary;
      case 'promo':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
