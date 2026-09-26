import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/notification_model.dart';
import '../../firebase_options.dart';
import 'firestore_rest_client.dart';

class FirebaseService {
  static bool isFirebaseConfigured = true;
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
      debugPrint('[FirebaseService] Successfully connected to Firebase Native (${effectiveOptions?.projectId ?? "default"})');
    } catch (e) {
      debugPrint('[FirebaseService] Native Firebase unavailable ($e). Utilizing transparent Firestore REST backend.');
      isFirebaseConfigured = true;
    }
  }

  // Firestore Collection references (when native plugin is active)
  static CollectionReference<Map<String, dynamic>>? get usersCollection =>
      firestore?.collection('users');

  static CollectionReference<Map<String, dynamic>>? get productsCollection =>
      firestore?.collection('products');

  static CollectionReference<Map<String, dynamic>>? get categoriesCollection =>
      firestore?.collection('categories');

  static CollectionReference<Map<String, dynamic>>? get ordersCollection =>
      firestore?.collection('orders');

  static CollectionReference<Map<String, dynamic>>? get reviewsCollection =>
      firestore?.collection('reviews');

  static CollectionReference<Map<String, dynamic>>? get notificationsCollection =>
      firestore?.collection('notifications');

  // =========================================================================
  // REAL-TIME STREAMS & FETCH METHODS (Unified for Native & REST backends)
  // =========================================================================

  // Products
  static Future<List<ProductModel>> fetchProducts() async {
    if (productsCollection != null) {
      try {
        final snap = await productsCollection!.get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => ProductModel.fromMap(d.data())).toList();
        }
      } catch (e) {
        debugPrint('[FirebaseService] Native fetchProducts error: $e');
      }
    }
    final rawList = await FirestoreRestClient.getCollection('products');
    return rawList.map((m) => ProductModel.fromMap(m)).toList();
  }

  static Stream<List<ProductModel>> streamProducts() {
    if (productsCollection != null) {
      return productsCollection!.snapshots().map(
            (snap) => snap.docs.map((d) => ProductModel.fromMap(d.data())).toList(),
          );
    }
    return FirestoreRestClient.streamCollection('products').map(
      (list) => list.map((m) => ProductModel.fromMap(m)).toList(),
    );
  }

  // Categories
  static Future<List<CategoryModel>> fetchCategories() async {
    if (categoriesCollection != null) {
      try {
        final snap = await categoriesCollection!.get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => CategoryModel.fromMap(d.data())).toList();
        }
      } catch (e) {
        debugPrint('[FirebaseService] Native fetchCategories error: $e');
      }
    }
    final rawList = await FirestoreRestClient.getCollection('categories');
    return rawList.map((m) => CategoryModel.fromMap(m)).toList();
  }

  static Stream<List<CategoryModel>> streamCategories() {
    if (categoriesCollection != null) {
      return categoriesCollection!.snapshots().map(
            (snap) => snap.docs.map((d) => CategoryModel.fromMap(d.data())).toList(),
          );
    }
    return FirestoreRestClient.streamCollection('categories').map(
      (list) => list.map((m) => CategoryModel.fromMap(m)).toList(),
    );
  }

  // Users
  static Future<List<UserModel>> fetchUsers() async {
    if (usersCollection != null) {
      try {
        final snap = await usersCollection!.get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => UserModel.fromMap(d.data())).toList();
        }
      } catch (e) {
        debugPrint('[FirebaseService] Native fetchUsers error: $e');
      }
    }
    final rawList = await FirestoreRestClient.getCollection('users');
    return rawList.map((m) => UserModel.fromMap(m)).toList();
  }

  static Stream<List<UserModel>> streamUsers() {
    if (usersCollection != null) {
      return usersCollection!.snapshots().map(
            (snap) => snap.docs.map((d) => UserModel.fromMap(d.data())).toList(),
          );
    }
    return FirestoreRestClient.streamCollection('users').map(
      (list) => list.map((m) => UserModel.fromMap(m)).toList(),
    );
  }

  // Orders
  static Future<List<OrderModel>> fetchOrders() async {
    if (ordersCollection != null) {
      try {
        final snap = await ordersCollection!.get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => OrderModel.fromMap(d.data())).toList();
        }
      } catch (e) {
        debugPrint('[FirebaseService] Native fetchOrders error: $e');
      }
    }
    final rawList = await FirestoreRestClient.getCollection('orders');
    return rawList.map((m) => OrderModel.fromMap(m)).toList();
  }

  static Stream<List<OrderModel>> streamOrders() {
    if (ordersCollection != null) {
      return ordersCollection!.snapshots().map(
            (snap) => snap.docs.map((d) => OrderModel.fromMap(d.data())).toList(),
          );
    }
    return FirestoreRestClient.streamCollection('orders').map(
      (list) => list.map((m) => OrderModel.fromMap(m)).toList(),
    );
  }

  // Reviews
  static Future<List<ReviewModel>> fetchReviews() async {
    if (reviewsCollection != null) {
      try {
        final snap = await reviewsCollection!.get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => ReviewModel.fromMap(d.data())).toList();
        }
      } catch (e) {
        debugPrint('[FirebaseService] Native fetchReviews error: $e');
      }
    }
    final rawList = await FirestoreRestClient.getCollection('reviews');
    return rawList.map((m) => ReviewModel.fromMap(m)).toList();
  }

  static Stream<List<ReviewModel>> streamReviews() {
    if (reviewsCollection != null) {
      return reviewsCollection!.snapshots().map(
            (snap) => snap.docs.map((d) => ReviewModel.fromMap(d.data())).toList(),
          );
    }
    return FirestoreRestClient.streamCollection('reviews').map(
      (list) => list.map((m) => ReviewModel.fromMap(m)).toList(),
    );
  }

  // Notifications
  static Future<List<NotificationModel>> fetchNotifications() async {
    if (notificationsCollection != null) {
      try {
        final snap = await notificationsCollection!.get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => NotificationModel.fromMap(d.data())).toList();
        }
      } catch (e) {
        debugPrint('[FirebaseService] Native fetchNotifications error: $e');
      }
    }
    final rawList = await FirestoreRestClient.getCollection('notifications');
    return rawList.map((m) => NotificationModel.fromMap(m)).toList();
  }

  static Stream<List<NotificationModel>> streamNotifications() {
    if (notificationsCollection != null) {
      return notificationsCollection!.snapshots().map(
            (snap) => snap.docs.map((d) => NotificationModel.fromMap(d.data())).toList(),
          );
    }
    return FirestoreRestClient.streamCollection('notifications').map(
      (list) => list.map((m) => NotificationModel.fromMap(m)).toList(),
    );
  }

  // =========================================================================
  // REAL-TIME SAVE, UPDATE & DELETE ACTIONS
  // =========================================================================

  // Products
  static Future<bool> saveProduct(ProductModel product) async {
    bool saved = false;
    try {
      await productsCollection?.doc(product.id).set(product.toMap());
      saved = true;
    } catch (_) {}
    final restSuccess = await FirestoreRestClient.setDocument('products', product.id, product.toMap());
    return saved || restSuccess;
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      await productsCollection?.doc(productId).delete();
    } catch (_) {}
    await FirestoreRestClient.deleteDocument('products', productId);
  }

  static Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await productsCollection?.doc(productId).update({'stock': newStock});
    } catch (_) {}
    await FirestoreRestClient.updateDocument('products', productId, {'stock': newStock});
  }

  // Categories
  static Future<void> saveCategory(CategoryModel category) async {
    try {
      await categoriesCollection?.doc(category.id).set(category.toMap());
    } catch (_) {}
    await FirestoreRestClient.setDocument('categories', category.id, category.toMap());
  }

  // Orders
  static Future<void> saveOrder(OrderModel order) async {
    try {
      await ordersCollection?.doc(order.id).set(order.toMap());
    } catch (_) {}
    await FirestoreRestClient.setDocument('orders', order.id, order.toMap());
  }

  static Future<void> updateOrderStatus(String orderId, String status) async {
    final updateData = {
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    try {
      await ordersCollection?.doc(orderId).update(updateData);
    } catch (_) {}
    await FirestoreRestClient.updateDocument('orders', orderId, updateData);
  }

  // Users
  static Future<void> saveUser(UserModel user) async {
    try {
      await usersCollection?.doc(user.id).set(user.toMap());
    } catch (_) {}
    await FirestoreRestClient.setDocument('users', user.id, user.toMap());
  }

  static Future<void> updateUserStatus(String userId, bool isSuspended) async {
    try {
      await usersCollection?.doc(userId).update({'isSuspended': isSuspended});
    } catch (_) {}
    await FirestoreRestClient.updateDocument('users', userId, {'isSuspended': isSuspended});
  }

  static Future<void> updateSellerVerification(String userId, bool isVerified) async {
    try {
      await usersCollection?.doc(userId).update({'isVerified': isVerified});
    } catch (_) {}
    await FirestoreRestClient.updateDocument('users', userId, {'isVerified': isVerified});
  }

  // Reviews
  static Future<void> saveReview(ReviewModel review) async {
    try {
      await reviewsCollection?.doc(review.id).set(review.toMap());
    } catch (_) {}
    await FirestoreRestClient.setDocument('reviews', review.id, review.toMap());
  }

  // Notifications
  static Future<void> saveNotification(NotificationModel notification) async {
    try {
      await notificationsCollection?.doc(notification.id).set(notification.toMap());
    } catch (_) {}
    await FirestoreRestClient.setDocument('notifications', notification.id, notification.toMap());
  }
}
