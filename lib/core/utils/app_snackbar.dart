import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void show(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
    SnackPosition? snackPosition,
    Duration? duration,
  }) {
    if (Get.context != null) {
      try {
        Get.snackbar(
          title,
          message,
          backgroundColor: backgroundColor,
          colorText: colorText,
          snackPosition: snackPosition ?? SnackPosition.BOTTOM,
          duration: duration ?? const Duration(seconds: 3),
        );
      } catch (_) {}
    }
  }
}
