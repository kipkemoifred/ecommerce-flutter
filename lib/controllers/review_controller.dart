import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/review_model.dart';
import '../core/utils/app_snackbar.dart';
import '../core/services/firebase_service.dart';
import 'product_controller.dart';

class ReviewController extends GetxController {
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    if (FirebaseService.isFirebaseConfigured) {
      _listenToFirestore();
    }
  }

  void _listenToFirestore() async {
    // 1. Immediate fetch from Firebase backend
    try {
      final initialReviews = await FirebaseService.fetchReviews();
      if (initialReviews.isNotEmpty) {
        reviews.assignAll(initialReviews);
      }
    } catch (e) {
      debugPrint('[ReviewController] Error during initial fetch: $e');
    }

    // 2. Real-time stream listeners from Firebase backend
    FirebaseService.streamReviews().listen((firestoreReviews) {
      reviews.assignAll(firestoreReviews);
    }, onError: (e) {
      debugPrint('[ReviewController] Reviews stream error: $e');
    });
  }

  List<ReviewModel> getReviewsForProduct(String productId) {
    return reviews.where((r) => r.productId == productId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  double getAverageRating(String productId) {
    final list = getReviewsForProduct(productId);
    if (list.isEmpty) return 5.0;
    final total = list.fold(0.0, (sum, r) => sum + r.rating);
    return double.parse((total / list.length).toStringAsFixed(1));
  }

  void addReview({
    required String productId,
    required String userId,
    required String userName,
    String? userAvatar,
    required double rating,
    required String comment,
  }) {
    final newReview = ReviewModel(
      id: 'rev_${const Uuid().v4().substring(0, 8)}',
      productId: productId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );

    reviews.insert(0, newReview);
    FirebaseService.saveReview(newReview);

    // Update product rating and review count
    try {
      final productController = Get.find<ProductController>();
      final prodIndex = productController.products.indexWhere((p) => p.id == productId);
      if (prodIndex != -1) {
        final currentProd = productController.products[prodIndex];
        final newAvg = getAverageRating(productId);
        productController.products[prodIndex] = currentProd.copyWith(
          rating: newAvg,
          reviewCount: currentProd.reviewCount + 1,
        );
      }
    } catch (_) {}

    AppSnackbar.show(
      'Review Submitted',
      'Thank you for your feedback! ⭐ $rating',
      backgroundColor: Colors.amber.shade50,
      colorText: Colors.amber.shade900,
    );
  }
}
