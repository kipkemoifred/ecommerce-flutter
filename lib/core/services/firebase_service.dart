import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/notification_model.dart';
import '../../firebase_options.dart';
import '../utils/dummy_data.dart';

class FirebaseService {
  static bool isFirebaseConfigured = false;
  static FirebaseAuth? auth;
  static FirebaseFirestore? firestore;

  static Future<void> init({FirebaseOptions? options}) async {
    try {
      FirebaseOptions? effectiveOptions = options;
      if (effectiveOptions == null) {
        try {
          effectiveOptions = DefaultFirebaseOptions.currentPlatform;
        } catch (_) {
          // Unsupported or non-configured platform (e.g. Linux desktop without web)
        }
      }

      if (effectiveOptions != null) {
        await Firebase.initializeApp(options: effectiveOptions);
      } else {
        await Firebase.initializeApp();
      }
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      isFirebaseConfigured = true;
      debugPrint('[FirebaseService] Successfully connected to Firebase Firestore & Auth (${effectiveOptions?.projectId ?? "default"})');

      // Seed initial dummy data to Firestore if database collections are empty
      await seedInitialDataToFirestore();
    } catch (e) {
      isFirebaseConfigured = false;
      debugPrint('[FirebaseService] Firebase connection in fallback mode ($e). Running seamlessly with reactive local store.');
    }
  }

  // Firestore Collection references
  static CollectionReference<Map<String, dynamic>>? get usersCollection =>
      isFirebaseConfigured ? firestore?.collection('users') : null;

  static CollectionReference<Map<String, dynamic>>? get productsCollection =>
      isFirebaseConfigured ? firestore?.collection('products') : null;

  static CollectionReference<Map<String, dynamic>>? get ordersCollection =>
      isFirebaseConfigured ? firestore?.collection('orders') : null;

  static CollectionReference<Map<String, dynamic>>? get reviewsCollection =>
      isFirebaseConfigured ? firestore?.collection('reviews') : null;

  static CollectionReference<Map<String, dynamic>>? get notificationsCollection =>
      isFirebaseConfigured ? firestore?.collection('notifications') : null;

  // --- Automatic Seed Method ---
  static Future<void> seedInitialDataToFirestore() async {
    if (!isFirebaseConfigured || firestore == null) return;

    try {
      final existingProducts = await productsCollection?.limit(1).get();
      if (existingProducts != null && existingProducts.docs.isEmpty) {
        debugPrint('[FirebaseService] Seeding initial marketplace data to Firestore...');
        final batch = firestore!.batch();

        for (final p in DummyData.initialProducts) {
          final doc = productsCollection!.doc(p.id);
          batch.set(doc, p.toMap());
        }

        for (final u in [DummyData.customerUser, DummyData.sellerUser, DummyData.adminUser]) {
          final doc = usersCollection!.doc(u.id);
          batch.set(doc, u.toMap());
        }

        for (final o in DummyData.initialOrders) {
          final doc = ordersCollection!.doc(o.id);
          batch.set(doc, o.toMap());
        }

        for (final r in DummyData.initialReviews) {
          final doc = reviewsCollection!.doc(r.id);
          batch.set(doc, r.toMap());
        }

        await batch.commit();
        debugPrint('[FirebaseService] Successfully seeded marketplace data to Firestore!');
      }
    } catch (e) {
      debugPrint('[FirebaseService] Firestore seeding error: $e');
    }
  }

  // --- Real-Time Save & Sync Methods ---

  // Products
  static Future<void> saveProduct(ProductModel product) async {
    if (!isFirebaseConfigured) return;
    try {
      await productsCollection?.doc(product.id).set(product.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving product to Firestore: $e');
    }
  }

  static Future<void> deleteProduct(String productId) async {
    if (!isFirebaseConfigured) return;
    try {
      await productsCollection?.doc(productId).delete();
    } catch (e) {
      debugPrint('[FirebaseService] Error deleting product from Firestore: $e');
    }
  }

  static Future<void> updateProductStock(String productId, int newStock) async {
    if (!isFirebaseConfigured) return;
    try {
      await productsCollection?.doc(productId).update({'stock': newStock});
    } catch (e) {
      debugPrint('[FirebaseService] Error updating stock on Firestore: $e');
    }
  }

  // Orders
  static Future<void> saveOrder(OrderModel order) async {
    if (!isFirebaseConfigured) return;
    try {
      await ordersCollection?.doc(order.id).set(order.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving order to Firestore: $e');
    }
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    if (!isFirebaseConfigured) return;
    try {
      await ordersCollection?.doc(orderId).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[FirebaseService] Error updating order status on Firestore: $e');
    }
  }

  // Users
  static Future<void> saveUser(UserModel user) async {
    if (!isFirebaseConfigured) return;
    try {
      await usersCollection?.doc(user.id).set(user.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving user to Firestore: $e');
    }
  }

  static Future<void> updateUserStatus(String userId, bool isSuspended) async {
    if (!isFirebaseConfigured) return;
    try {
      await usersCollection?.doc(userId).update({'isSuspended': isSuspended});
    } catch (e) {
      debugPrint('[FirebaseService] Error updating user status on Firestore: $e');
    }
  }

  static Future<void> updateSellerVerification(String userId, bool isVerified) async {
    if (!isFirebaseConfigured) return;
    try {
      await usersCollection?.doc(userId).update({'isVerified': isVerified});
    } catch (e) {
      debugPrint('[FirebaseService] Error updating seller verification on Firestore: $e');
    }
  }

  // Reviews
  static Future<void> saveReview(ReviewModel review) async {
    if (!isFirebaseConfigured) return;
    try {
      await reviewsCollection?.doc(review.id).set(review.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving review to Firestore: $e');
    }
  }

  // Notifications
  static Future<void> saveNotification(NotificationModel notification) async {
    if (!isFirebaseConfigured) return;
    try {
      await notificationsCollection?.doc(notification.id).set(notification.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving notification to Firestore: $e');
    }
  }
}
