import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/discount_controller.dart';
import '../../user_base/controllers/user_base_controller.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/services/discount_service.dart';
import '../../../../app/services/product_service.dart';

class DiscountView extends GetView<DiscountController> {
  const DiscountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
            size: 18,
          ),
          onPressed: () {
            // If navigated via Get.toNamed (has a route stack), pop normally.
            // If opened as a bottom nav tab (IndexedStack), switch to Home tab.
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.find<UserBaseController>().onTabSelected(0);
            }
          },
        ),
        title: Text(
          'OFFERS & DISCOUNTS',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              top: false,
              bottom: true,
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => ProductService.to.refreshCatalogFromServer(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActiveDiscountBanner(),
                      const SizedBox(height: 24),
                      Text(
                        'Boost Your Discount',
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _buildBoostCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDiscountBanner() {
    return Obx(() {
      final pct = controller.currentDiscount.value.toStringAsFixed(0);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Active Discount',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$pct% OFF',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Applied on your next order',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBoostCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Watch an Ad, Get More Off',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Watch a short ad to boost your discount',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final ds = DiscountService.to;
            final min = 0.0;
            final max = ds.maxDiscountPercent.toDouble();
            final pct = controller.currentDiscount.value;
            final range = (max - min).abs() < 0.001 ? 1.0 : (max - min);
            final progress = ((pct - min) / range).clamp(0.0, 1.0);
            final need = ds.adsNeededForNextPercent;
            final watched = ds.adsWatchedCount.value;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current: ${pct.toStringAsFixed(0)}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Max: ${max.toStringAsFixed(0)}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pct >= max
                      ? 'You reached the maximum discount of ${max.toStringAsFixed(0)}%.'
                      : 'You have ${pct.toStringAsFixed(0)}% off. Watch ads to boost this further (progress: $watched/$need ads to next +1%).',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final adsOn = ProductService.to.adsRewardEnabled.value;
            if (!adsOn) {
              return Text(
                'Ad rewards are paused by the store. Check back later.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              );
            }
            return SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.isShowingRewardAd.value
                      ? null
                      : controller.watchAdAndBoostDiscount,
                  icon: controller.isShowingRewardAd.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.play_circle_outline, size: 20),
                  label: Text(
                    controller.isShowingRewardAd.value
                        ? 'Loading Ad...'
                        : 'Watch Ad to Boost',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
