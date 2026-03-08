import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/services/auth_service.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService.to;

  Future<void> signOut() async {
    // Show confirmation dialog before signing out
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.5),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Sign Out',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _authService.signOut();
    // Clear entire navigation stack and go to auth screen
    Get.offAllNamed(Routes.AUTH);
  }
}
