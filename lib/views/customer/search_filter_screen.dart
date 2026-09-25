import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../core/constants/app_colors.dart';
import '../common/product_card.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ProductController>();
    _searchController.text = controller.searchQuery.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context, ProductController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Products',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.resetFilters();
                            setModalState(() {});
                            Get.back();
                          },
                          child: const Text('Reset All'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Categories
                    const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Obx(() => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.categories.map((cat) {
                            final isSel = controller.selectedCategory.value == cat.name;
                            return ChoiceChip(
                              label: Text(cat.name),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) {
                                controller.selectedCategory.value = cat.name;
                                setModalState(() {});
                              },
                            );
                          }).toList(),
                        )),
                    const SizedBox(height: 16),

                    // Price Range Slider
                    Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(
                                '\$${controller.minPrice.value.toInt()} - \$${controller.maxPrice.value.toInt()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          RangeSlider(
                            values: RangeValues(controller.minPrice.value, controller.maxPrice.value),
                            min: 0,
                            max: 1000,
                            divisions: 20,
                            activeColor: AppColors.primary,
                            onChanged: (values) {
                              controller.minPrice.value = values.start;
                              controller.maxPrice.value = values.end;
                              setModalState(() {});
                            },
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),

                    // Minimum Rating Filter
                    const Text('Minimum Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Obx(() {
                      return Row(
                        children: [4.0, 3.0, 2.0, 0.0].map((star) {
                          final isSel = controller.minRating.value == star;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(star == 0.0 ? 'All' : '${star.toInt()}+'),
                                ],
                              ),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary),
                              onSelected: (_) {
                                controller.minRating.value = star;
                                setModalState(() {});
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 16),

                    // In Stock Only Switch
                    Obx(() => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('In Stock Only', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          value: controller.inStockOnly.value,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) {
                            controller.inStockOnly.value = val;
                            setModalState(() {});
                          },
                        )),
                    const SizedBox(height: 16),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => controller.setSearchQuery(val),
            decoration: InputDecoration(
              hintText: 'Search electronics, shoes, fashion...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        controller.setSearchQuery('');
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showFilterModal(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Sort Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Result count
                Obx(() => Text(
                      '${controller.filteredProducts.length} Results',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    )),
                // Sort Dropdown
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.sortBy.value,
                          isDense: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          items: [
                            'Featured',
                            'Price: Low to High',
                            'Price: High to Low',
                            'Top Rated',
                            'Newest',
                          ].map((sort) {
                            return DropdownMenuItem(value: sort, child: Text(sort));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.sortBy.value = val;
                          },
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const Divider(height: 1),

          // Active filter chips
          Obx(() {
            final hasFilters = controller.selectedCategory.value != 'All' ||
                controller.minPrice.value > 0 ||
                controller.maxPrice.value < 1000 ||
                controller.minRating.value > 0 ||
                controller.inStockOnly.value;

            if (!hasFilters) return const SizedBox.shrink();

            return Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (controller.selectedCategory.value != 'All')
                    _buildActiveChip(
                      controller.selectedCategory.value,
                      () => controller.selectedCategory.value = 'All',
                    ),
                  if (controller.minPrice.value > 0 || controller.maxPrice.value < 1000)
                    _buildActiveChip(
                      '\$${controller.minPrice.value.toInt()} - \$${controller.maxPrice.value.toInt()}',
                      () {
                        controller.minPrice.value = 0;
                        controller.maxPrice.value = 1000;
                      },
                    ),
                  if (controller.minRating.value > 0)
                    _buildActiveChip(
                      '${controller.minRating.value.toInt()}+ Stars',
                      () => controller.minRating.value = 0,
                    ),
                  if (controller.inStockOnly.value)
                    _buildActiveChip(
                      'In Stock',
                      () => controller.inStockOnly.value = false,
                    ),
                ],
              ),
            );
          }),

          // Products Grid
          Expanded(
            child: Obx(() {
              final items = controller.filteredProducts;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No matching products found',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Try adjusting your search query or filter criteria',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _searchController.clear();
                          controller.resetFilters();
                        },
                        child: const Text('Reset All Filters'),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: items[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onDeleted,
        backgroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
