import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../app/services/ad_service.dart';
import '../../../../app/theme/app_colors.dart';

class DiscountController extends GetxController {
  final currentDiscount = AppConstants.minDiscountPercent.obs;
  final isShowingRewardAd = false.obs;

  void setDiscount(double value) {
    if (value < AppConstants.minDiscountPercent) {
      currentDiscount.value = AppConstants.minDiscountPercent;
    } else if (value > AppConstants.maxDiscountPercent) {
      currentDiscount.value = AppConstants.maxDiscountPercent;
    } else {
      currentDiscount.value = value;
    }
  }

  Future<void> watchAdAndBoostDiscount() async {
    if (isShowingRewardAd.value) return;
    isShowingRewardAd.value = true;
    try {
      final shown = await AdService.instance.showRewardedAd(
        onUserEarnedReward: (_) {
          // As per your policy: each completed ad gives +0.25%
          setDiscount(currentDiscount.value + 0.25);
          Get.snackbar(
            'Discount Boosted',
            'Your discount is now ${currentDiscount.value.toStringAsFixed(2)}% OFF',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
          );
        },
      );

      if (!shown) {
        Get.snackbar(
          'Ad Not Ready',
          'Please wait a moment and try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(12),
        );
      }
    } finally {
      isShowingRewardAd.value = false;
    }
  }
}

