import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/discount_controller.dart';
import '../../user_base/controllers/user_base_controller.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';

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
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark, size: 18),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActiveDiscountBanner(),
            const SizedBox(height: 24),
            Text('Available Coupons', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            ..._coupons.map((c) => _CouponCard(coupon: c)),
            const SizedBox(height: 24),
            Text('Boost Your Discount', style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            _buildBoostCard(),
            const SizedBox(height: 32),
          ],
        ),
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
              child: const Icon(Icons.local_offer_rounded,
                  color: Colors.white, size: 36),
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
                child: const Icon(Icons.bolt_rounded,
                    color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Watch an Ad, Get More Off',
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.w600)),
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
            final pct = controller.currentDiscount.value;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current: ${pct.toStringAsFixed(0)}%',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.primary)),
                    Text('Max: 20%',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (pct - 5) / 15,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.secondary),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                controller.setDiscount(
                    (controller.currentDiscount.value + 5)
                        .clamp(5, 20)
                        .toDouble());
                Get.snackbar(
                  '🎉 Discount Boosted!',
                  'Your discount is now ${controller.currentDiscount.value.toStringAsFixed(0)}% OFF',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(12),
                );
              },
              icon: const Icon(Icons.play_circle_outline, size: 20),
              label: const Text('Watch Ad to Boost'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coupon data model ──────────────────────────────────────────────────────────

class _CouponData {
  final String code;
  final String title;
  final String description;
  final String discount;
  final Color color;
  final IconData icon;
  final bool isActive;

  const _CouponData({
    required this.code,
    required this.title,
    required this.description,
    required this.discount,
    required this.color,
    required this.icon,
    this.isActive = true,
  });
}

const _coupons = [
  _CouponData(
    code: 'FIRST20',
    title: 'First Order Discount',
    description: 'Get 20% off on your very first order',
    discount: '20% OFF',
    color: AppColors.secondary,
    icon: Icons.celebration_outlined,
  ),
  _CouponData(
    code: 'OUD10',
    title: 'Oud Collection',
    description: '10% off on all Oud fragrances',
    discount: '10% OFF',
    color: AppColors.accent,
    icon: Icons.spa_outlined,
  ),
  _CouponData(
    code: 'FREESHIP',
    title: 'Free Delivery',
    description: 'Free delivery on orders above PKR 3000',
    discount: 'FREE\nSHIPPING',
    color: AppColors.success,
    icon: Icons.local_shipping_outlined,
  ),
  _CouponData(
    code: 'SUMMER15',
    title: 'Summer Sale',
    description: '15% off on selected summer scents',
    discount: '15% OFF',
    color: AppColors.primary,
    icon: Icons.wb_sunny_outlined,
    isActive: false,
  ),
];

// ── Coupon card ────────────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  final _CouponData coupon;

  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: coupon.isActive ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left colored strip with discount
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: coupon.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(coupon.icon, color: Colors.white, size: 26),
                    const SizedBox(height: 6),
                    Text(
                      coupon.discount,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Dashed separator
              _DashedDivider(color: coupon.color),
              // Right content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              coupon.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!coupon.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Expired',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: coupon.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: coupon.color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              coupon.code,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: coupon.color,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (coupon.isActive)
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: coupon.code));
                                Get.snackbar(
                                  'Copied!',
                                  '${coupon.code} copied to clipboard.',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: coupon.color,
                                  colorText: Colors.white,
                                  borderRadius: 12,
                                  margin: const EdgeInsets.all(12),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.copy_rounded,
                                      size: 14,
                                      color: coupon.color
                                          .withValues(alpha: 0.7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Copy',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: coupon.color
                                          .withValues(alpha: 0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  final Color color;

  const _DashedDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: CustomPaint(
        painter: _DashedLinePainter(color: color),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double y = 0;
    const dashHeight = 5;
    const gapHeight = 4;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashHeight),
        paint,
      );
      y += dashHeight + gapHeight;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
