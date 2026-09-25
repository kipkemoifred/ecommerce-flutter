import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firebase_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../common/role_selector_dialog.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final orderController = Get.find<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch Marketplace Role',
            onPressed: RoleSelectorDialog.show,
          ),
        ],
      ),
      body: Obx(() {
        final user = auth.currentUser.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Please sign in to view your profile'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          );
        }

        final myOrders = orderController.getCustomerOrders(user.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(user.avatarUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Activity Stats Row
              Row(
                children: [
                  _buildStatCard('Orders Placed', '${myOrders.length}', Icons.shopping_bag_outlined),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Total Spent',
                    CurrencyFormatter.format(user.totalSpent),
                    Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Marketplace Role Switcher Banner
              InkWell(
                onTap: RoleSelectorDialog.show,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.dashboard_customize_outlined, color: Colors.white, size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Switch Marketplace Perspective',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Explore as Customer, Seller, or Admin',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Profile Settings Options
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      title: const Text('Default Delivery Address'),
                      subtitle: Text(user.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                      title: const Text('Phone Number'),
                      subtitle: Text(user.phone),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        FirebaseService.isFirebaseConfigured ? Icons.cloud_done : Icons.cloud_queue,
                        color: FirebaseService.isFirebaseConfigured ? Colors.green : Colors.amber.shade800,
                      ),
                      title: const Text('Backend & Firebase Status'),
                      subtitle: Text(
                        FirebaseService.isFirebaseConfigured
                            ? 'Connected to Firebase Firestore & Auth'
                            : 'Reactive Local & Mock Storage (Ready for Firebase)',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Get.snackbar(
                          'Backend Status',
                          FirebaseService.isFirebaseConfigured
                              ? 'Firebase is configured and live.'
                              : 'App is running in responsive offline/seed mode. Ready to plug in Firebase credentials anytime.',
                        );
                      },
                    ),
                  ],
                ),
              ),
              ),
              const SizedBox(height: 24),

              // Logout
              OutlinedButton.icon(
                onPressed: () {
                  auth.logout();
                  Get.offAll(() => const LoginScreen());
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
