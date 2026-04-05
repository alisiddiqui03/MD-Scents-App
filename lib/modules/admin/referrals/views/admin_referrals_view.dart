import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/services/admin_referrals_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/utils/order_action_time.dart';
import '../controllers/admin_referrals_controller.dart';

/// Full scrollable list of referral-linked orders + date filter + tap for Firestore order detail.
class AdminReferralsView extends GetView<AdminReferralsController> {
  const AdminReferralsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Referral orders',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textDark,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Obx(() {
            final hasFilter = controller.dateRange.value != null;
            if (hasFilter) {
              return TextButton(
                onPressed: controller.clearDateFilter,
                child: Text(
                  'Clear filter',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            tooltip: 'Filter by date',
            onPressed: () => controller.pickDateRange(context),
            icon: const Icon(Icons.date_range_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          AdminReferralsService.to.isLoading.value;
          AdminReferralsService.to.rows.length;
          controller.dateRange.value;

          final loading = AdminReferralsService.to.isLoading.value;
          final rows = controller.filteredRows();

          if (loading && AdminReferralsService.to.rows.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: AppColors.textDark.withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.dateRange.value != null
                          ? 'No referrals in this date range.'
                          : 'No referral orders yet.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.55),
                      ),
                    ),
                    if (controller.dateRange.value != null) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: controller.clearDateFilter,
                        child: const Text('Show all'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() {
                final r = controller.dateRange.value;
                if (r == null) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      '${rows.length} referral${rows.length == 1 ? '' : 's'} · tap a row for full order',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        color: AppColors.textDark.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${rows.length} in range · ${_fmtRange(r)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final r = rows[i];
                    return _ReferralListTile(
                      row: r,
                      onTap: () => controller.openOrderDetail(r),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  static String _fmtRange(DateTimeRange r) =>
      '${r.start.day}/${r.start.month}/${r.start.year} → ${r.end.day}/${r.end.month}/${r.end.year}';
}

class _ReferralListTile extends StatelessWidget {
  final AdminReferralRow row;
  final VoidCallback onTap;

  const _ReferralListTile({
    required this.row,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = row.status == 'completed';
    final statusColor =
        completed ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);
    final name = (row.referredUserName != null &&
            row.referredUserName!.trim().isNotEmpty)
        ? row.referredUserName!.trim()
        : 'Buyer ${row.referredUserId.length > 8 ? row.referredUserId.substring(0, 8) : row.referredUserId}…';
    final orderShort = row.orderId.length > 10
        ? '${row.orderId.substring(0, 10)}…'
        : row.orderId;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                            fontSize: 15,
                          ),
                        ),
                        if (row.referredUserEmail != null &&
                            row.referredUserEmail!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            row.referredUserEmail!.trim(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 12,
                              color: AppColors.textDark.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      completed ? 'Reward done' : 'Pending',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Order #$orderShort · PKR ${row.rewardAmount.toStringAsFixed(0)} reward',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.textDark.withValues(alpha: 0.65),
                ),
              ),
              if (row.createdAt != null)
                Text(
                  'Referral logged · ${formatOrderActionTime(row.createdAt)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textDark.withValues(alpha: 0.45),
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'View order',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
