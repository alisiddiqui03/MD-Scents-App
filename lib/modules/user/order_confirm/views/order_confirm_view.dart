import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_pages.dart';

class OrderConfirmView extends StatelessWidget {
  const OrderConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    // Arguments passed from CartController
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final orderId = args['orderId'] as String? ?? '#MD-00001';
    final total = args['total'] as String? ?? 'PKR 0';
    final isCod = args['isCod'] as bool? ?? true;
    final itemCount = args['itemCount'] as int? ?? 1;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // ── Success animation circle ──────────────────────────────
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (_, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Title ─────────────────────────────────────────────────
                Text(
                  'Order Placed!',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  isCod
                      ? 'Your order has been placed.\nPay cash when it arrives.'
                      : 'Your order is confirmed.\nWe will verify your payment receipt shortly.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.55),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // ── Order summary card ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.tag_rounded,
                        label: 'Order ID',
                        value: orderId,
                        valueColor: AppColors.primary,
                      ),
                      const SizedBox(height: 14),
                      _InfoRow(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Items',
                        value: '$itemCount item${itemCount > 1 ? 's' : ''}',
                      ),
                      const SizedBox(height: 14),
                      _InfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Payment',
                        value: isCod ? 'Cash on Delivery' : 'Bank Transfer',
                      ),
                      const SizedBox(height: 14),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 14),
                      _InfoRow(
                        icon: Icons.receipt_long_outlined,
                        label: 'Total',
                        value: total,
                        valueColor: AppColors.primary,
                        bold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Status timeline ───────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What happens next?',
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      _StepRow(
                        icon: Icons.check_circle_rounded,
                        label: 'Order Received',
                        done: true,
                      ),
                      _StepRow(
                        icon: isCod
                            ? Icons.inventory_2_outlined
                            : Icons.verified_outlined,
                        label: isCod
                            ? 'Being Prepared'
                            : 'Payment Verification',
                        done: false,
                      ),
                      _StepRow(
                        icon: Icons.local_shipping_outlined,
                        label: 'Shipped to You',
                        done: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Buttons ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(Routes.USER_BASE);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text('Back to Home',
                        style: AppTextStyles.buttonText),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.offAllNamed(Routes.USER_BASE);
                      // Switch to Orders tab after navigation settles
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Get.toNamed(Routes.USER_ORDERS);
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('View My Orders',
                        style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: valueColor ?? AppColors.textDark,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            fontSize: bold ? 15 : 13,
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool done;
  final bool isLast;

  const _StepRow({
    required this.icon,
    required this.label,
    required this.done,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AppColors.success
                    : AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                icon,
                size: 16,
                color: done
                    ? Colors.white
                    : AppColors.textDark.withValues(alpha: 0.35),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: done
                    ? AppColors.success.withValues(alpha: 0.3)
                    : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: done
                  ? AppColors.success
                  : AppColors.textDark.withValues(alpha: 0.45),
              fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
