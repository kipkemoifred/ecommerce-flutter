import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/product_model.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_snackbar.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _stockController = TextEditingController(text: '10');
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Electronics';
  List<String> _images = [];
  bool _isFeatured = false;
  bool _isSaving = false;

  // Preset image library for quick 1-tap testing
  final List<String> _presetImages = [
    'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600',
    'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600',
    'https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=600',
    'https://images.unsplash.com/photo-1627123424574-724758594e93?w=600',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _titleController.text = p.title;
      _descController.text = p.description;
      _priceController.text = p.price.toString();
      _originalPriceController.text = p.originalPrice?.toString() ?? '';
      _stockController.text = p.stock.toString();
      _selectedCategory = p.category;
      _images = List.from(p.images);
      _isFeatured = p.isFeatured;
    } else {
      _images = [_presetImages[0]];
      _isFeatured = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // If the seller typed/pasted a URL without clicking "Add", automatically include it
    if (_imageUrlController.text.trim().isNotEmpty) {
      final url = _imageUrlController.text.trim();
      if (!_images.contains(url)) {
        _images.add(url);
      }
      _imageUrlController.clear();
    }

    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      AppSnackbar.show(
        'Image Required',
        'Please select at least one image or enter an image URL.',
        backgroundColor: Colors.orange.shade50,
      );
      return;
    }

    setState(() => _isSaving = true);

    final productController = Get.find<ProductController>();
    final auth = Get.find<AuthController>();
    final user = auth.currentUser.value;

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final origPriceText = _originalPriceController.text.trim();
    final origPrice = origPriceText.isNotEmpty ? double.tryParse(origPriceText) : null;
    final stock = int.tryParse(_stockController.text.trim()) ?? 10;

    final resolvedSellerId = (user != null && user.isSeller) ? user.id : 'user_sell_1';
    final resolvedSellerName = (user != null && user.isSeller && user.storeName.isNotEmpty)
        ? user.storeName
        : (user?.name ?? 'TechNest Official');

    final now = DateTime.now();

    bool success;
    if (widget.product != null) {
      final updated = widget.product!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: price,
        originalPrice: origPrice,
        stock: stock,
        category: _selectedCategory,
        images: _images.isNotEmpty ? _images : [_presetImages[0]],
        isFeatured: _isFeatured,
      );
      success = await productController.updateProduct(updated);
    } else {
      final newProd = ProductModel(
        id: 'prod_${const Uuid().v4().substring(0, 8)}',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: price,
        originalPrice: origPrice,
        category: _selectedCategory,
        images: _images.isNotEmpty ? _images : [_presetImages[0]],
        sellerId: resolvedSellerId,
        sellerName: resolvedSellerName,
        stock: stock,
        isFeatured: _isFeatured,
        isApproved: true,
        createdAt: now,
      );
      success = await productController.addProduct(newProd);
    }

    if (mounted) {
      if (success) {
        Get.back();
      } else {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final productController = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload / Preset Picker Section
              const Text(
                'Product Images',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose from presets or enter an image URL:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),

              // Active images previews
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _images[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                        if (_images.length > 1)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () => setState(() => _images.removeAt(index)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Preset quick image chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _presetImages.map((img) {
                    final isPicked = _images.contains(img);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          if (!isPicked) {
                            setState(() => _images.add(img));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isPicked ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(img, width: 44, height: 44, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Custom URL input
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          hintText: 'Or paste image URL...',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_imageUrlController.text.trim().isNotEmpty) {
                        setState(() {
                          _images.add(_imageUrlController.text.trim());
                          _imageUrlController.clear();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Product Title',
                hintText: 'e.g. Noise Cancelling Studio Headphones',
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Category dropdown (Safely wrapped in Obx with complete fallback categories)
              const Text('Category', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
              const SizedBox(height: 6),
              Obx(() {
                final categoryNames = <String>{
                  'Electronics',
                  'Fashion',
                  'Footwear',
                  'Gaming',
                  'Home & Living',
                  ...productController.categories
                      .map((c) => c.name)
                      .where((n) => n.toLowerCase() != 'all'),
                  _selectedCategory,
                }.toList()..sort();

                final effectiveValue = categoryNames.contains(_selectedCategory)
                    ? _selectedCategory
                    : categoryNames.first;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: effectiveValue,
                      items: categoryNames
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCategory = v);
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Pricing Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Price (\$)',
                      hintText: '199.99',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null || val <= 0) return 'Enter a valid price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _originalPriceController,
                      label: 'Original Price (\$, optional)',
                      hintText: '249.99',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Inventory Stock
              CustomTextField(
                controller: _stockController,
                label: 'Available Stock Quantity',
                hintText: '25',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final val = int.tryParse(v);
                  if (val == null || val < 0) return 'Must be a positive number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                controller: _descController,
                label: 'Product Description',
                hintText: 'Highlight key features, material, specifications, and warranty...',
                maxLines: 4,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 16),

              // Featured Product Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Feature on Marketplace',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Highlight this product on the marketplace home screen',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  value: _isFeatured,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isFeatured = val),
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button with reactive loading state
              CustomButton(
                text: isEditing ? 'Save Changes' : 'Publish Product to Marketplace',
                backgroundColor: AppColors.sellerBadge,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _handleSave,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
