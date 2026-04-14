import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wallet_controller.dart';
import '../../../../app/data/models/referral_entry.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/services/wallet_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/utils/order_action_time.dart';
import '../../../../app/widgets/app_branded_loading.dart';
import '../../../../app/data/models/points_history.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

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
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              // Fallback to Profile/Home via UserBaseController if we can't pop
              Get.back(closeOverlays: true);
            }
          },
        ),
        title: Text(
          'My Wallet',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 0.5),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final user = AuthService.to.currentUser.value;
        if (user == null) return const AppBrandedLoading();

        WalletService.to.balance.value;
        WalletService.to.pendingRewards.value;
        final bal = WalletService.to.balance.value;
        final pend = WalletService.to.pendingRewards.value;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary.withValues(alpha: 0.92),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total credit available',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PKR ${bal.toStringAsFixed(0)}',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (pend > 0.009) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Pending from referrals: PKR ${pend.toStringAsFixed(0)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      'Use this amount at checkout (cart) toggle “Apply wallet balance” when you have items in the cart.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Referral rewards history',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'PKR 500 per completed referral (after their first order is delivered).',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.textDark.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final list = controller.entries;
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No referral rewards yet. Share your code from Refer & Earn — '
                      'when a friend completes their first order, you will see entries here.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.55),
                        height: 1.5,
                      ),
                    ),
                  );
                }
                return Column(
                  children: list.map((e) => _rewardTile(e)).toList(),
                );
              }),
              const SizedBox(height: 28),
              _buildPointsSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _rewardTile(ReferralEntry e) {
    final st = e.status == ReferralStatus.completed ? 'Completed' : 'Pending';
    final stColor = e.status == ReferralStatus.completed
        ? AppColors.success
        : AppColors.accent;
    final name =
        (e.referredUserName != null && e.referredUserName!.trim().isNotEmpty)
        ? e.referredUserName!.trim()
        : 'Friend (${e.referredUserId.length > 6 ? e.referredUserId.substring(0, 6) : e.referredUserId}…)';
    final email =
        (e.referredUserEmail != null && e.referredUserEmail!.trim().isNotEmpty)
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
                      color: AppColors.textDark.withValues(alpha: 0.65),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Order $orderShort',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textDark.withValues(alpha: 0.45),
                  ),
                ),
                if (e.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Started: ${formatOrderActionTime(e.createdAt)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 10,
                      color: AppColors.textDark.withValues(alpha: 0.4),
                    ),
                  ),
                ],
                if (e.completedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Credited: ${formatOrderActionTime(e.completedAt)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 10,
                      color: AppColors.success.withValues(alpha: 0.9),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
  }

  Widget _buildPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Points',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${WalletService.to.points.value} pts',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    final pts = WalletService.to.points.value;
                    final canRedeem = pts >= 500;
                    return ElevatedButton(
                      onPressed: canRedeem
                          ? () => _showRedeemConfirmDialog()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        disabledForegroundColor: Colors.grey.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: controller.isRedeeming.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Redeem',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    );
                  }),
                ],
              ),
              const Divider(height: 32),
              Text(
                'Redeem 500 points for PKR 2500 wallet credit.',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.textDark.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Points history',
          style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final list = controller.pointsHistory;
          if (list.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No points history yet. Earn points by setting your birthday and reviewing products!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.55),
                  height: 1.5,
                ),
              ),
            );
          }
          return Column(
            children: list.map((e) => _pointsHistoryTile(e)).toList(),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _pointsHistoryTile(PointHistoryItem e) {
    final isNegative = e.points < 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isNegative ? Colors.orange : AppColors.success)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNegative ? Icons.redeem_rounded : Icons.add_task_rounded,
              color: isNegative ? Colors.orange : AppColors.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatOrderActionTime(e.createdAt),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textDark.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${e.points > 0 ? '+' : ''}${e.points}',
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isNegative ? Colors.red : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  void _showRedeemConfirmDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Redeem Points', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to redeem 500 points for PKR 2500 credit?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.5),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.redeemPoints();
            },
            child: Text(
              'Redeem',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
