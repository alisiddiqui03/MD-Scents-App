import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Consistent admin feedback (success / error / info) — use after add, update, delete, etc.
class AdminSnackbar {
  AdminSnackbar._();

  static const _radius = 12.0;
  static const _margin = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const _duration = Duration(seconds: 2);

  static void success(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      borderRadius: _radius,
      margin: _margin,
      duration: _duration,
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22),
    );
  }

  static void error(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      borderRadius: _radius,
      margin: _margin,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 22),
    );
  }

  static void info(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      borderRadius: _radius,
      margin: _margin,
      duration: _duration,
      icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 22),
    );
  }
}
