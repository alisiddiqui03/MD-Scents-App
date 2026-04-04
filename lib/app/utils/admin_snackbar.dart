import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Consistent admin feedback — high contrast, below status bar, no blur wash-out.
class AdminSnackbar {
  AdminSnackbar._();

  static const _radius = 14.0;
  static const _durationShort = Duration(seconds: 3);
  static const _durationLong = Duration(seconds: 4);

  static List<BoxShadow> get _shadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.22),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  static TextStyle get _titleStyle => GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0.2,
      );

  static TextStyle get _messageStyle => GoogleFonts.montserrat(
        color: Colors.white.withValues(alpha: 0.96),
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        height: 1.45,
      );

  static EdgeInsets _margin() {
    final ctx = Get.context;
    final top = ctx != null ? MediaQuery.paddingOf(ctx).top : 44.0;
    return EdgeInsets.fromLTRB(14, top + 6, 14, 0);
  }

  static double _maxWidth() {
    final w = Get.width;
    if (w.isFinite && w > 0) {
      return math.min(520, w - 28);
    }
    return 520;
  }

  static void success(String title, String message) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_rounded,
      duration: _durationShort,
    );
  }

  static void error(String title, String message) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.danger,
      icon: Icons.error_rounded,
      duration: _durationLong,
    );
  }

  static void info(String title, String message) {
    _show(
      title: title,
      message: message,
      backgroundColor: AppColors.primary,
      icon: Icons.info_rounded,
      duration: _durationShort,
    );
  }

  /// New customer order(s) while admin is in the app — matches theme (solid, no blur).
  static void newOrderAlert(int count) {
    if (count <= 0) return;
    _show(
      title: 'New order${count > 1 ? 's' : ''}',
      message: count == 1
          ? 'You have a new customer order. Open Orders to review.'
          : 'You have $count new orders. Open Orders to review.',
      backgroundColor: AppColors.primary,
      icon: Icons.receipt_long_rounded,
      duration: _durationLong,
    );
  }

  static void _show({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required Duration duration,
  }) {
    Get.snackbar(
      '',
      '',
      titleText: Text(title, style: _titleStyle),
      messageText: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          message,
          style: _messageStyle,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      // Critical: default Get.snackbar uses barBlur 7 — washes out solid colors.
      barBlur: 0,
      shouldIconPulse: false,
      borderRadius: _radius,
      margin: _margin(),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      maxWidth: _maxWidth(),
      duration: duration,
      icon: Icon(icon, color: Colors.white, size: 26),
      boxShadows: _shadow,
      animationDuration: const Duration(milliseconds: 350),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      dismissDirection: DismissDirection.up,
    );
  }
}
