import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/refer_earn_controller.dart';
import '../../../../app/data/models/referral_entry.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/utils/order_action_time.dart';
import '../../../../app/widgets/app_branded_loading.dart';

class ReferEarnView extends GetView<ReferEarnController> {
  const ReferEarnView({super.key});

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
          onPressed: () => Get.back(),
        ),
        title: Text(
          'REFER & EARN',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final user = AuthService.to.currentUser.value;
        if (user == null) return const AppBrandedLoading();

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your code',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      controller.isLoadingCode.value;
                      final code = controller.referralCode ?? '—';
                      return Text(
                        code,
                        style: AppTextStyles.headlineMedium.copyWith(
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isLoadingCode.value
                            ? null
                            : controller.shareCode,
                        icon: const Icon(Icons.ios_share_rounded, size: 20),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Invited friends',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Obx(() {
                final list = controller.entries;
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'When someone uses your code on their first order, they get free delivery. '
                      'You earn PKR 500 store credit (pending) until that order is marked '
                      'Delivered & Paid.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.55),
                        height: 1.5,
                      ),
                    ),
                  );
                }
                return Column(
                  children: list.map((e) {
                    final st = e.status == ReferralStatus.completed
                        ? 'Completed'
                        : 'Pending';
                    final stColor = e.status == ReferralStatus.completed
                        ? AppColors.success
                        : AppColors.accent;
                    final name = (e.referredUserName != null &&
                            e.referredUserName!.trim().isNotEmpty)
                        ? e.referredUserName!.trim()
                        : 'Friend (${e.referredUserId.length > 6 ? e.referredUserId.substring(0, 6) : e.referredUserId}…)';
                    final email = (e.referredUserEmail != null &&
                            e.referredUserEmail!.trim().isNotEmpty)
                        ? e.referredUserEmail!.trim()
                        : null;
                    final orderShort = e.orderId.length > 10
                        ? '${e.orderId.substring(0, 10)}…'
                        : e.orderId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                if (email != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 12,
                                      color: AppColors.textDark
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  'Order $orderShort',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textDark
                                        .withValues(alpha: 0.45),
                                  ),
                                ),
                                if (e.createdAt != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Started: ${formatOrderActionTime(e.createdAt)}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 10,
                                      color: AppColors.textDark
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                                if (e.completedAt != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Completed: ${formatOrderActionTime(e.completedAt)}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 10,
                                      color: AppColors.success
                                          .withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: stColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  st,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: stColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'PKR ${e.rewardAmount.toStringAsFixed(0)}',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
