import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/services/ad_service.dart';
import '../../../../app/services/discount_service.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/theme/app_colors.dart';

class DiscountController extends GetxController {
  final currentDiscount = 0.0.obs;
  final isShowingRewardAd = false.obs;

  late final Worker _syncFromService;

  @override
  void onInit() {
    super.onInit();
    currentDiscount.value = DiscountService.to.currentDiscountPercent.value;
    _syncFromService = ever(
      DiscountService.to.currentDiscountPercent,
      (v) => currentDiscount.value = (v as num).toDouble(),
    );
  }

  @override
  void onClose() {
    _syncFromService.dispose();
    super.onClose();
  }

  Future<void> watchAdAndBoostDiscount() async {
    if (isShowingRewardAd.value) return;

    final ps = ProductService.to;
    final discount = DiscountService.to;
    if (!ps.adsRewardEnabled.value) {
      Get.snackbar(
        'Offers paused',
        'Ad rewards are temporarily disabled by the store.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    // Important: while welcome 5% is active, DO NOT open ad.
    if (discount.isWelcomeDiscountActive) {
      Get.snackbar(
        'Welcome discount active',
        'Please use your 5% welcome discount first. After that, ads will start boosting your discount.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    isShowingRewardAd.value = true;
    try {
      final before = discount.currentDiscountPercent.value;
      final result = await AdService.instance.presentRewardedAd(
        onUserEarnedReward: (_) {},
      );

      if (!result.presentationStarted) {
        Get.snackbar(
          'Ad unavailable',
          result.fallbackMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(12),
        );
      } else if (!result.rewardEarned) {
        final hint = result.incompleteRewardHint;
        if (hint.isNotEmpty) {
          Get.snackbar(
            'Almost there',
            hint,
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
          );
        }
      } else if (result.rewardEarned) {
        await discount.onRewardedAdEarned();
        final after = discount.currentDiscountPercent.value;
        currentDiscount.value = after;
        final gained = (after - before).clamp(0, 20).toDouble();
        final need = discount.adsNeededForNextPercent;
        final watched = discount.adsWatchedCount.value;
        Get.snackbar(
          gained > 0 ? 'Discount Boosted' : 'Progress saved',
          gained > 0
              ? 'Your discount is now ${after.toStringAsFixed(0)}% OFF'
              : 'Ad watched. Progress: $watched / $need toward next +1%',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(12),
        );
      }
    } finally {
      currentDiscount.value = DiscountService.to.currentDiscountPercent.value;
      isShowingRewardAd.value = false;
    }
  }
}
