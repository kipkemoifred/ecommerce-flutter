import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';

class AppSnackbar {
  static void show(
    String title,
    String message, {
    Color? backgroundColor,
    Color? colorText,
    SnackPosition? snackPosition,
    Duration? duration,
  }) {
    final ctx = Get.context;
    if (ctx == null) return;

    try {
      final messenger = ScaffoldMessenger.maybeOf(ctx);
      if (messenger != null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorText ?? Colors.white,
                    ),
                  ),
                if (title.isNotEmpty && message.isNotEmpty)
                  const SizedBox(height: 2),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12,
                      color: (colorText ?? Colors.white).withValues(alpha: 0.95),
                    ),
                  ),
              ],
            ),
            backgroundColor: backgroundColor ?? AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: duration ?? const Duration(seconds: 3),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
        return;
      }
    } catch (_) {}

    // Fallback safely after current frame completes layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (Get.context != null) {
          Get.snackbar(
            title,
            message,
            backgroundColor: backgroundColor,
            colorText: colorText,
            snackPosition: snackPosition ?? SnackPosition.BOTTOM,
            duration: duration ?? const Duration(seconds: 3),
          );
        }
      } catch (_) {}
    });
  }
}
