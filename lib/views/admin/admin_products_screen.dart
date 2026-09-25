import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/product_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();
    final productController = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog Moderation'),
      ),
      body: Obx(() {
        final products = adminController.allProducts;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = products[index];

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(p.mainImage, width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text('Seller: ${p.sellerName} • Category: ${p.category}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text(CurrencyFormatter.format(p.price), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Featured toggle chip
                      InkWell(
                        onTap: () => adminController.toggleProductFeatured(p.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: p.isFeatured ? Colors.amber.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: p.isFeatured ? Colors.amber : Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 14, color: p.isFeatured ? Colors.amber : Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                p.isFeatured ? 'Featured' : 'Not Featured',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: p.isFeatured ? Colors.amber.shade900 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Approve / Disapprove switch
                      Row(
                        children: [
                          Text(p.isApproved ? 'Approved' : 'Hidden', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Switch(
                            value: p.isApproved,
                            activeThumbColor: Colors.green,
                            onChanged: (_) => adminController.toggleProductApproval(p.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () {
                              Get.defaultDialog(
                                title: 'Remove Product',
                                middleText: 'Delete ${p.title} from catalog permanently?',
                                textConfirm: 'Delete',
                                textCancel: 'Cancel',
                                confirmTextColor: Colors.white,
                                buttonColor: AppColors.error,
                                onConfirm: () {
                                  productController.deleteProduct(p.id);
                                  Get.back();
                                },
                              );
                            },
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
}
