import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/seller_controller.dart';
import '../../controllers/product_controller.dart';
import '../../data/models/product_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import 'add_edit_product_screen.dart';

class SellerProductsScreen extends StatelessWidget {
  const SellerProductsScreen({super.key});

  void _showUpdateStockDialog(BuildContext context, ProductModel product, ProductController controller) {
    int stock = product.stock;
    final textController = TextEditingController(text: '$stock');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Update Inventory Stock', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Units',
                  prefixIcon: Icon(Icons.inventory),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newStock = int.tryParse(textController.text) ?? stock;
                controller.updateStock(product.id, newStock);
                Get.back();
              },
              child: const Text('Save Stock'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sellerController = Get.find<SellerController>();
    final productController = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Inventory'),
      ),
      body: Obx(() {
        final products = sellerController.myProducts;

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text('No products listed yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Tap the button below to add your first product.', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                  onPressed: () => Get.to(() => const AddEditProductScreen()),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 65,
                      height: 65,
                      child: Image.network(
                        product.mainImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(product.price),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: product.stock > 10
                                    ? Colors.green.shade50
                                    : (product.stock > 0 ? Colors.amber.shade50 : Colors.red.shade50),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: product.stock > 10
                                      ? Colors.green.shade200
                                      : (product.stock > 0 ? Colors.amber.shade300 : Colors.red.shade300),
                                ),
                              ),
                              child: Text(
                                product.stock > 0 ? '${product.stock} units' : 'Out of stock',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: product.stock > 10
                                      ? Colors.green.shade800
                                      : (product.stock > 0 ? Colors.amber.shade900 : Colors.red.shade800),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _showUpdateStockDialog(context, product, productController),
                              child: const Text(
                                'Edit Stock',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') {
                        Get.to(() => AddEditProductScreen(product: product));
                      } else if (val == 'delete') {
                        Get.defaultDialog(
                          title: 'Delete Product',
                          middleText: 'Are you sure you want to delete ${product.title}?',
                          textConfirm: 'Delete',
                          textCancel: 'Cancel',
                          confirmTextColor: Colors.white,
                          buttonColor: AppColors.error,
                          onConfirm: () {
                            productController.deleteProduct(product.id);
                            Get.back();
                          },
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit Details')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.sellerBadge,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Get.to(() => const AddEditProductScreen()),
      ),
    );
  }
}
