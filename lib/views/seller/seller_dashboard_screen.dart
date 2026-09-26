import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../controllers/seller_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../common/app_drawer.dart';
import '../common/role_selector_dialog.dart';
import 'seller_products_screen.dart';
import 'add_edit_product_screen.dart';
import 'seller_orders_screen.dart';
import 'seller_sales_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject seller controller if not already present
    final sellerController = Get.put(SellerController());
    final auth = Get.find<AuthController>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Obx(() {
          final user = auth.currentUser.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.storeName.isNotEmpty == true ? user!.storeName : 'Seller Portal',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const Text('Merchant Operations Center', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          );
        }),
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
            // Store Status & Verification Banner
            Obx(() {
              final user = auth.currentUser.value;
              final isVerified = user?.isVerified ?? false;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isVerified ? AppColors.sellerBadge.withValues(alpha: 0.08) : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isVerified ? AppColors.sellerBadge.withValues(alpha: 0.3) : Colors.amber.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isVerified ? Icons.verified_user : Icons.pending_actions,
                      color: isVerified ? AppColors.sellerBadge : Colors.amber.shade800,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isVerified ? 'Verified Seller Account' : 'Verification Under Review',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isVerified ? AppColors.sellerBadge : Colors.amber.shade900,
                            ),
                          ),
                          Text(
                            isVerified
                                ? 'Your products are active in the public marketplace.'
                                : 'Admin approval required for public listing visibility.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Top Metric Cards Grid
            Obx(() {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _buildMetricTile(
                    title: 'Total Revenue',
                    value: CurrencyFormatter.format(sellerController.totalRevenue),
                    icon: Icons.monetization_on_outlined,
                    color: Colors.green,
                  ),
                  _buildMetricTile(
                    title: 'Active Products',
                    value: '${sellerController.activeProductsCount}',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                  _buildMetricTile(
                    title: 'Incoming Orders',
                    value: '${sellerController.pendingOrdersCount}',
                    icon: Icons.local_shipping_outlined,
                    color: Colors.orange,
                  ),
                  _buildMetricTile(
                    title: 'Completed Orders',
                    value: '${sellerController.totalCompletedOrders}',
                    icon: Icons.check_circle_outline,
                    color: Colors.teal,
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Sales Trend Graph Card (fl_chart)
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
                      const Text(
                        'Weekly Sales Performance',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => const SellerSalesScreen()),
                        child: const Text('Detailed Analytics →'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final maxSale = sellerController.weeklySalesData.fold(0.0, (m, v) => v > m ? v : m);
                      final effectiveMaxY = maxSale > 1200 ? (maxSale * 1.25) : 1500.0;
                      return SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: effectiveMaxY,
                            barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              getTitlesWidget: (val, _) => Text(
                                '\$${val.toInt()}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, _) {
                                final idx = val.toInt();
                                if (idx >= 0 && idx < sellerController.weeklySalesDays.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      sellerController.weeklySalesDays[idx],
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          sellerController.weeklySalesData.length,
                          (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: sellerController.weeklySalesData[i],
                                color: AppColors.sellerBadge,
                                width: 14,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Operations Row
            const Text(
              'Seller Tools',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Add Product',
                    icon: Icons.add_box_outlined,
                    color: AppColors.primary,
                    onTap: () => Get.to(() => const AddEditProductScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    title: 'Inventory',
                    icon: Icons.warehouse_outlined,
                    color: AppColors.sellerBadge,
                    onTap: () => Get.to(() => const SellerProductsScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    title: 'Orders',
                    icon: Icons.assignment_outlined,
                    color: Colors.teal,
                    onTap: () => Get.to(() => const SellerOrdersScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Customer Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Store Orders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const SellerOrdersScreen()),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentOrders(sellerController),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.sellerBadge,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => Get.to(() => const AddEditProductScreen()),
      ),
    );
  }

  Widget _buildMetricTile({
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
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(SellerController controller) {
    return Obx(() {
      final orders = controller.myOrders;
      if (orders.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No orders received yet.'),
          ),
        );
      }

      final recent = orders.take(3).toList();
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recent.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final o = recent[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${o.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(o.customerName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(o.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(o.status, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
