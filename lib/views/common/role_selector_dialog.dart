import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../customer/customer_main_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class RoleSelectorDialog extends StatelessWidget {
  const RoleSelectorDialog({super.key});

  static void show() {
    Get.dialog(const RoleSelectorDialog());
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Switch Marketplace Role',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Instantly explore features across all 3 user roles:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Customer Option
            _buildRoleCard(
              title: 'Customer Experience',
              subtitle: 'Shop, Cart, Wishlist, Checkout, Tracking, Reviews',
              icon: Icons.shopping_bag_outlined,
              color: AppColors.customerBadge,
              isSelected: auth.isCustomer,
              onTap: () {
                auth.switchDemoRole(AppConstants.roleCustomer);
                Get.back();
                Get.offAll(() => const CustomerMainScreen());
              },
            ),
            const SizedBox(height: 10),

            // Seller Option
            _buildRoleCard(
              title: 'Seller Dashboard',
              subtitle: 'Add Products, Inventory, Manage Orders, Sales Trends',
              icon: Icons.storefront_outlined,
              color: AppColors.sellerBadge,
              isSelected: auth.isSeller,
              onTap: () {
                auth.switchDemoRole(AppConstants.roleSeller);
                Get.back();
                Get.offAll(() => const SellerDashboardScreen());
              },
            ),
            const SizedBox(height: 10),

            // Admin Option
            _buildRoleCard(
              title: 'Admin Governance',
              subtitle: 'Manage Users, Verify Sellers, Moderate Catalog, Analytics',
              icon: Icons.admin_panel_settings_outlined,
              color: AppColors.adminBadge,
              isSelected: auth.isAdmin,
              onTap: () {
                auth.switchDemoRole(AppConstants.roleAdmin);
                Get.back();
                Get.offAll(() => const AdminDashboardScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
