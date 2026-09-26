import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/notification_model.dart';
import '../core/services/firebase_service.dart';

class NotificationController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

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
      final initialNotifs = await FirebaseService.fetchNotifications();
      if (initialNotifs.isNotEmpty) {
        notifications.assignAll(initialNotifs);
      }
    } catch (e) {
      debugPrint('[NotificationController] Error during initial fetch: $e');
    }

    // 2. Real-time stream listeners from Firebase backend
    FirebaseService.streamNotifications().listen((firestoreNotifs) {
      notifications.assignAll(firestoreNotifs);
    }, onError: (e) {
      debugPrint('[NotificationController] Notifications stream error: $e');
    });
  }

  List<NotificationModel> getUserNotifications(String userId) {
    return notifications
        .where((n) => n.userId == userId || n.userId == 'all')
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  int getUnreadCount(String userId) {
    return notifications
        .where((n) => (n.userId == userId || n.userId == 'all') && !n.isRead)
        .length;
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  void markAllAsRead(String userId) {
    for (var n in notifications) {
      if (n.userId == userId || n.userId == 'all') {
        n.isRead = true;
      }
    }
    notifications.refresh();
  }

  void addNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) {
    final notif = NotificationModel(
      id: 'notif_${const Uuid().v4().substring(0, 8)}',
      userId: userId,
      title: title,
      message: message,
      type: type,
      relatedId: relatedId,
      timestamp: DateTime.now(),
      isRead: false,
    );
    notifications.insert(0, notif);
    FirebaseService.saveNotification(notif);
  }
}
