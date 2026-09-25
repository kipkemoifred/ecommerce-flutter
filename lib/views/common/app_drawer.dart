import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_service.dart';
import '../customer/customer_main_screen.dart';
import '../seller/seller_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';
import 'role_selector_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Drawer(
      child: Obx(() {
        final user = auth.currentUser.value;
        final role = auth.currentRole;

        return Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  user?.avatarUrl ??
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                ),
              ),
              accountName: Row(
                children: [
                  Text(
                    user?.name ?? 'Guest User',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              accountEmail: Text(user?.email ?? 'Sign in to access all features'),
            ),

            // Firebase status indicator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: FirebaseService.isFirebaseConfigured
                    ? Colors.green.shade50
                    : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: FirebaseService.isFirebaseConfigured
                      ? Colors.green.shade200
                      : Colors.amber.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FirebaseService.isFirebaseConfigured
                        ? Icons.cloud_done
                        : Icons.cloud_queue,
                    size: 18,
                    color: FirebaseService.isFirebaseConfigured
                        ? Colors.green.shade800
                        : Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      FirebaseService.isFirebaseConfigured
                          ? 'Firebase: Live Cloud Sync Active'
                          : 'Storage: Local Reactive Cache (Ready)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: FirebaseService.isFirebaseConfigured
                            ? Colors.green.shade900
                            : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
                    title: const Text('Switch Role (Demo)'),
                    subtitle: const Text('Toggle Customer / Seller / Admin'),
                    onTap: () {
                      Get.back();
                      RoleSelectorDialog.show();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.storefront, color: AppColors.customerBadge),
                    title: const Text('Customer Marketplace'),
                    selected: auth.isCustomer,
                    onTap: () {
                      Get.back();
                      auth.switchDemoRole(AppConstants.roleCustomer);
                      Get.offAll(() => const CustomerMainScreen());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard_customize, color: AppColors.sellerBadge),
                    title: const Text('Seller Dashboard'),
                    selected: auth.isSeller,
                    onTap: () {
                      Get.back();
                      auth.switchDemoRole(AppConstants.roleSeller);
                      Get.offAll(() => const SellerDashboardScreen());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings, color: AppColors.adminBadge),
                    title: const Text('Admin Dashboard'),
                    selected: auth.isAdmin,
                    onTap: () {
                      Get.back();
                      auth.switchDemoRole(AppConstants.roleAdmin);
                      Get.offAll(() => const AdminDashboardScreen());
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Authentication Screen'),
                    subtitle: const Text('Test Login & Registration'),
                    onTap: () {
                      Get.back();
                      Get.to(() => const LoginScreen());
                    },
                  ),
                ],
              ),
            ),

            // Logout / Sign in footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: auth.isLoggedIn
                  ? OutlinedButton.icon(
                      onPressed: () {
                        auth.logout();
                        Get.back();
                        Get.to(() => const LoginScreen());
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size.fromHeight(45),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.to(() => const LoginScreen());
                      },
                      child: const Text('Sign In / Register'),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
