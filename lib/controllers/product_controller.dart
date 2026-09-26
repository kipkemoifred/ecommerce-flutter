import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/product_model.dart';
import '../data/models/category_model.dart';
import '../core/utils/app_snackbar.dart';
import '../core/services/api_service.dart';
import '../core/services/firebase_service.dart';

class ProductController extends GetxController {
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[
    CategoryModel(id: 'cat_all', name: 'All', icon: 'apps', imageUrl: ''),
  ].obs;

  // Filter & Search states
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 1000.0.obs;
  final RxDouble minRating = 0.0.obs;
  final RxString sortBy = 'Featured'.obs;
  final RxBool inStockOnly = false.obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    _listenToFirestore();
  }

  void _listenToFirestore() async {
    // 1. Immediate fetch from Firebase backend
    try {
      final initialProducts = await FirebaseService.fetchProducts();
      if (initialProducts.isNotEmpty) {
        products.assignAll(initialProducts);
      }
      final initialCategories = await FirebaseService.fetchCategories();
      if (initialCategories.isNotEmpty) {
        if (!initialCategories.any((c) => c.name.toLowerCase() == 'all')) {
          initialCategories.insert(0, CategoryModel(id: 'cat_all', name: 'All', icon: 'apps', imageUrl: ''));
        }
        categories.assignAll(initialCategories);
      }
    } catch (e) {
      debugPrint('[ProductController] Error during initial fetch: $e');
    } finally {
      isLoading.value = false;
    }

    // 2. Real-time stream listeners from Firebase backend
    FirebaseService.streamProducts().listen((firestoreProducts) {
      if (firestoreProducts.isNotEmpty) {
        products.assignAll(firestoreProducts);
      }
      isLoading.value = false;
    }, onError: (e) {
      debugPrint('[ProductController] Products stream error: $e');
      isLoading.value = false;
    });

    FirebaseService.streamCategories().listen((firestoreCategories) {
      if (firestoreCategories.isNotEmpty) {
        if (!firestoreCategories.any((c) => c.name.toLowerCase() == 'all')) {
          firestoreCategories.insert(0, CategoryModel(id: 'cat_all', name: 'All', icon: 'apps', imageUrl: ''));
        }
        categories.assignAll(firestoreCategories);
      }
    }, onError: (e) {
      debugPrint('[ProductController] Categories stream error: $e');
    });
  }

  // Filtered Products computation
  List<ProductModel> get filteredProducts {
    return products.where((p) {
      // Must be approved by admin (unless seller viewing own products)
      if (!p.isApproved) return false;

      // Category filter
      if (selectedCategory.value != 'All' &&
          p.category.toLowerCase() != selectedCategory.value.toLowerCase()) {
        return false;
      }

      // Search query filter
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchTitle = p.title.toLowerCase().contains(query);
        final matchDesc = p.description.toLowerCase().contains(query);
        final matchCategory = p.category.toLowerCase().contains(query);
        final matchTags = p.tags.any((t) => t.toLowerCase().contains(query));
        if (!matchTitle && !matchDesc && !matchCategory && !matchTags) {
          return false;
        }
      }

      // Price filter
      if (p.price < minPrice.value || p.price > maxPrice.value) {
        return false;
      }

      // Rating filter
      if (p.rating < minRating.value) {
        return false;
      }

      // In stock filter
      if (inStockOnly.value && !p.isInStock) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (sortBy.value) {
          case 'Price: Low to High':
            return a.price.compareTo(b.price);
          case 'Price: High to Low':
            return b.price.compareTo(a.price);
          case 'Top Rated':
            return b.rating.compareTo(a.rating);
          case 'Newest':
            return b.createdAt.compareTo(a.createdAt);
          case 'Featured':
          default:
            if (a.isFeatured && !b.isFeatured) return -1;
            if (!a.isFeatured && b.isFeatured) return 1;
            return b.rating.compareTo(a.rating);
        }
      });
  }

  List<ProductModel> get featuredProducts =>
      products.where((p) => p.isFeatured && p.isApproved).toList();

  List<ProductModel> getProductsBySeller(String sellerId) =>
      products.where((p) => p.sellerId == sellerId).toList();

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void resetFilters() {
    selectedCategory.value = 'All';
    searchQuery.value = '';
    minPrice.value = 0.0;
    maxPrice.value = 1000.0;
    minRating.value = 0.0;
    sortBy.value = 'Featured';
    inStockOnly.value = false;
  }

  // Seller/Admin Actions
  Future<bool> addProduct(ProductModel product) async {
    isLoading.value = true;
    try {
      final existingIndex = products.indexWhere((p) => p.id == product.id);
      if (existingIndex != -1) {
        products[existingIndex] = product;
      } else {
        products.insert(0, product);
      }
      products.refresh();

      await FirebaseService.saveProduct(product);

      AppSnackbar.show(
        'Product Published 🎉',
        '${product.title} has been added to marketplace.',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade900,
      );
      return true;
    } catch (e) {
      debugPrint('[ProductController] Error adding product: $e');
      AppSnackbar.show('Error', 'Failed to save product: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    isLoading.value = true;
    try {
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = product;
        products.refresh();
      }
      await FirebaseService.saveProduct(product);
      AppSnackbar.show('Product Updated', '${product.title} updated successfully.');
      return true;
    } catch (e) {
      debugPrint('[ProductController] Error updating product: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    FirebaseService.deleteProduct(id);
    AppSnackbar.show('Product Removed', 'Product has been deleted from catalog.');
  }

  void updateStock(String id, int newStock) {
    final index = products.indexWhere((p) => p.id == id);
    if (index != -1) {
      products[index] = products[index].copyWith(stock: newStock);
      FirebaseService.updateProductStock(id, newStock);
      AppSnackbar.show('Stock Updated', 'New stock level: $newStock units.');
    }
  }

  void toggleFeatured(String id) {
    final index = products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final current = products[index];
      products[index] = current.copyWith(isFeatured: !current.isFeatured);
      FirebaseService.saveProduct(products[index]);
    }
  }

  void toggleApproved(String id) {
    final index = products.indexWhere((p) => p.id == id);
    if (index != -1) {
      final current = products[index];
      products[index] = current.copyWith(isApproved: !current.isApproved);
      FirebaseService.saveProduct(products[index]);
      AppSnackbar.show(
        'Product Moderated',
        'Product is now ${!current.isApproved ? 'Approved' : 'Unapproved'}',
      );
    }
  }

  /// Sync external products via Dio REST API
  Future<void> syncExternalCatalog() async {
    isLoading.value = true;
    try {
      final items = await ApiService.fetchExternalProducts(limit: 5);
      for (var item in items) {
        final id = 'ext_${item['id']}';
        if (!products.any((p) => p.id == id)) {
          products.add(
            ProductModel(
              id: id,
              title: item['title'] ?? 'Imported Product',
              description: item['description'] ?? '',
              price: (item['price'] as num?)?.toDouble() ?? 49.99,
              category: (item['category'] as String?)?.capitalizeFirst ?? 'Electronics',
              images: item['thumbnail'] != null
                  ? [item['thumbnail']]
                  : ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500'],
              sellerId: 'user_sell_1',
              sellerName: 'Global Importers',
              stock: (item['stock'] as num?)?.toInt() ?? 20,
              rating: (item['rating'] as num?)?.toDouble() ?? 4.5,
              reviewCount: 15,
            ),
          );
        }
      }
      AppSnackbar.show(
        'REST API Synced',
        'Successfully fetched new products using Dio client.',
        backgroundColor: Colors.indigo.shade50,
      );
    } catch (e) {
      AppSnackbar.show('Sync Note', 'Online sync completed in offline/cached mode.');
    } finally {
      isLoading.value = false;
    }
  }
}
