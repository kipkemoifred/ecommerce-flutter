import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../core/constants/app_colors.dart';

class AdminSellersScreen extends StatelessWidget {
  const AdminSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Sellers & Stores'),
      ),
      body: Obx(() {
        final sellers = adminController.sellers;

        if (sellers.isEmpty) {
          return const Center(child: Text('No sellers registered.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sellers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final seller = sellers[index];

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
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(seller.avatarUrl),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seller.storeName.isNotEmpty ? seller.storeName : seller.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(seller.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: seller.isVerified ? Colors.green.shade50 : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: seller.isVerified ? Colors.green.shade200 : Colors.amber.shade300,
                          ),
                        ),
                        child: Text(
                          seller.isVerified ? 'Verified' : 'Pending',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: seller.isVerified ? Colors.green.shade800 : Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (seller.storeDescription.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      seller.storeDescription,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location: ${seller.address}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!seller.isVerified)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check, size: 14),
                          label: const Text('Approve Store', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            minimumSize: const Size(120, 34),
                          ),
                          onPressed: () => adminController.verifySeller(seller.id),
                        )
                      else
                        const Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text('Approved Vendor', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
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
}
