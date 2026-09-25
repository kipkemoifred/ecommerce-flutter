import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../common/app_drawer.dart';
import '../common/role_selector_dialog.dart';
import 'admin_users_screen.dart';
import 'admin_sellers_screen.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_analytics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.put(AdminController());

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ShopNest Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('Marketplace Governance & Control', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch Role',
            onPressed: RoleSelectorDialog.show,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Overview Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Platform Health & Overview', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                        CurrencyFormatter.format(adminController.totalMarketplaceRevenue),
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                      )),
                  const Text('Total Marketplace Gross Merchandise Value (GMV)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pending Approvals Alert
            Obx(() {
              final pending = adminController.pendingSellerApprovals;
              if (pending == 0) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notification_important, color: Colors.amber, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$pending seller verification requests awaiting review.',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber.shade900),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const AdminSellersScreen()),
                      child: const Text('Review'),
                    ),
                  ],
                ),
              );
            }),

            // 4 Stats Cards
            Obx(() {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatTile(
                    title: 'Total Customers',
                    value: '${adminController.customers.length}',
                    icon: Icons.people_outline,
                    color: Colors.blue,
                  ),
                  _buildStatTile(
                    title: 'Active Sellers',
                    value: '${adminController.sellers.length}',
                    icon: Icons.store_outlined,
                    color: Colors.purple,
                  ),
                  _buildStatTile(
                    title: 'Catalog Items',
                    value: '${adminController.allProducts.length}',
                    icon: Icons.inventory_2_outlined,
                    color: Colors.orange,
                  ),
                  _buildStatTile(
                    title: 'Total Orders',
                    value: '${adminController.totalOrdersCount}',
                    icon: Icons.receipt_long_outlined,
                    color: Colors.green,
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Revenue Growth Line Chart
            Container(
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
                      const Text('Platform Revenue Growth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      TextButton(
                        onPressed: () => Get.to(() => const AdminAnalyticsScreen()),
                        child: const Text('Full Report →'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        maxY: 25000,
                        minY: 10000,
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: (v, _) => Text(
                                '\$${(v / 1000).toInt()}k',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final idx = v.toInt();
                                if (idx >= 0 && idx < adminController.monthsLabels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(adminController.monthsLabels[idx], style: const TextStyle(fontSize: 11)),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: AppColors.adminBadge,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.adminBadge.withValues(alpha: 0.12),
                            ),
                            spots: List.generate(
                              adminController.monthlyRevenueData.length,
                              (i) => FlSpot(i.toDouble(), adminController.monthlyRevenueData[i]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Management Navigation Hub
            const Text('Administrative Modules', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildNavRow(
              title: 'Manage Customers',
              subtitle: 'View customer accounts, total spending, ban/unban status',
              icon: Icons.people_alt_outlined,
              color: Colors.blue,
              onTap: () => Get.to(() => const AdminUsersScreen()),
            ),
            const SizedBox(height: 10),
            _buildNavRow(
              title: 'Manage Sellers',
              subtitle: 'Verify new merchants, inspect store metrics and compliance',
              icon: Icons.storefront_outlined,
              color: Colors.purple,
              onTap: () => Get.to(() => const AdminSellersScreen()),
            ),
            const SizedBox(height: 10),
            _buildNavRow(
              title: 'Product Catalog Moderation',
              subtitle: 'Approve, feature, or remove products across all vendors',
              icon: Icons.inventory_outlined,
              color: Colors.orange,
              onTap: () => Get.to(() => const AdminProductsScreen()),
            ),
            const SizedBox(height: 10),
            _buildNavRow(
              title: 'Platform Orders',
              subtitle: 'Track and oversee fulfillment across all marketplace stores',
              icon: Icons.receipt_long_outlined,
              color: Colors.teal,
              onTap: () => Get.to(() => const AdminOrdersScreen()),
            ),
            const SizedBox(height: 10),
            _buildNavRow(
              title: 'Marketplace Analytics',
              subtitle: 'Comprehensive financial, category, and sales breakdown',
              icon: Icons.insights_outlined,
              color: AppColors.adminBadge,
              onTap: () => Get.to(() => const AdminAnalyticsScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNavRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
