import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/models/order.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/utils/order_action_time.dart';
import '../controllers/admin_referral_detail_controller.dart';

class AdminReferralOrderDetailView extends GetView<AdminReferralDetailController> {
  const AdminReferralOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Referral order',
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
          Obx(
            () => IconButton(
              tooltip: 'Refresh',
              onPressed:
                  controller.isLoading.value ? null : () => controller.reload(),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.order.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final err = controller.errorMessage.value;
        final r = controller.row;
        if (r == null) {
          return _MessageCenter(
            icon: Icons.error_outline_rounded,
            text: err ?? 'Something went wrong.',
          );
        }

        if (err != null && controller.order.value == null) {
          return _MessageCenter(
            icon: Icons.inventory_2_outlined,
            text: err,
            child: TextButton(
              onPressed: controller.reload,
              child: const Text('Retry'),
            ),
          );
        }

        final o = controller.order.value;
        if (o == null) {
          return _MessageCenter(
            icon: Icons.help_outline_rounded,
            text: 'No order data.',
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.reload,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _SectionCard(
                title: 'Referral record',
                children: [
                  _refDetailKv('Referrer (wallet) UID', r.referrerUid),
                  _refDetailKv('Buyer UID', r.referredUserId),
                  _refDetailKv('Reward', 'PKR ${r.rewardAmount.toStringAsFixed(0)}'),
                  _refDetailKv('Status', r.status),
                  if (r.createdAt != null)
                    _refDetailKv('Logged', formatOrderActionTime(r.createdAt)),
                  if (r.completedAt != null)
                    _refDetailKv('Completed', formatOrderActionTime(r.completedAt)),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Order summary',
                children: [
                  _refDetailKv('Order ID', o.id),
                  _refDetailKv('Placed', formatOrderActionTime(o.createdAt)),
                  _refDetailKv('Status', o.status.name),
                  _refDetailKv('Payment', o.isPaid ? 'Paid' : 'Unpaid'),
                  _refDetailKv('Method', o.isCod ? 'Cash on delivery' : 'Bank transfer'),
                  _refDetailKv('Total', 'PKR ${o.total.toStringAsFixed(0)}'),
                  if (o.merchandiseTotal > 0.009)
                    _refDetailKv('Merchandise', 'PKR ${o.merchandiseTotal.toStringAsFixed(0)}'),
                  if (o.walletAppliedAmount > 0.009)
                    _refDetailKv(
                      'Store credit used',
                      'PKR ${o.walletAppliedAmount.toStringAsFixed(0)}',
                    ),
                  if (o.bankTransferDiscountAmount > 0.009)
                    _refDetailKv(
                      'Bank discount (5%)',
                      '− PKR ${o.bankTransferDiscountAmount.toStringAsFixed(0)}',
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Customer',
                children: [
                  _refDetailKv('Name', o.customerName),
                  _refDetailKv('Email', o.customerEmail.isEmpty ? '—' : o.customerEmail),
                  _refDetailKv('Phone', o.deliveryPhone.isEmpty ? '—' : o.deliveryPhone),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Delivery',
                children: [
                  _refDetailKv(
                    'Address',
                    o.deliverySummaryLine.isNotEmpty
                        ? o.deliverySummaryLine
                        : (o.deliveryStreet.isNotEmpty ? o.deliveryStreet : '—'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Items (${o.items.length})',
                children: o.items
                    .map(
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                i.productName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${i.quantity} × PKR ${i.price.toStringAsFixed(0)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.textDark.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Referral on this order',
                children: [
                  _refDetailKv('Code used', o.referralCodeEntered ?? '—'),
                  _refDetailKv('Referrer UID', o.referredBy ?? '—'),
                  _refDetailKv('Reward state', o.referralStatusLabel),
                  _refDetailKv('Free delivery perk', o.referralFreeDelivery ? 'Yes' : 'No'),
                ],
              ),
              if (o.status == OrderStatus.cancelled &&
                  (o.cancellationReason?.trim().isNotEmpty ?? false)) ...[
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Cancellation',
                  children: [
                    Text(
                      o.cancellationReason!.trim(),
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.35),
                    ),
                    if (o.cancelledAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          formatOrderActionTime(o.cancelledAt),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textDark.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

Widget _refDetailKv(String k, String v) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              k,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                color: AppColors.textDark.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              v,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _MessageCenter extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? child;

  const _MessageCenter({
    required this.icon,
    required this.text,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.textDark.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.6),
              ),
            ),
            if (child != null) ...[const SizedBox(height: 12), child!],
          ],
        ),
      ),
    );
  }
}
