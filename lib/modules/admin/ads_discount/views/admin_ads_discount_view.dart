import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../inventory/controllers/inventory_controller.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/services/product_service.dart';

/// Ads flow info + user discount monitor (moved from Inventory tab).
class AdminAdsDiscountView extends GetView<InventoryController> {
  const AdminAdsDiscountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ads & user discounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ProductService.to.refreshCatalogFromServer(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ProductService.to.refreshCatalogFromServer(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AdminDiscountCard(),
                      const SizedBox(height: 12),
                      _AdminUserDiscountMonitor(controller: controller),
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

class _AdminDiscountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<InventoryController>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2A44), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ads & Discount',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.info_outline_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome discount is fixed at 5%. Ad progression is fixed up to 20%.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '0-5: 1 ad/+1%  •  5-10: 2 ads/+1%  •  10-15: 4 ads/+1%  •  15-20: 8 ads/+1%',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showAdsConfigSheet(c),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('View flow details'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdsConfigSheet(InventoryController c) {
    c.syncAdConfigFromProductService();
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Ads discount flow', style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Text(
              'User discount progression now follows fixed rules. You can enable or disable ad rewards below.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome discount', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    '• First-time user gets 5% once\n'
                    '• User must use this 5% before ad boosts start',
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ad progression (fixed)',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• 0% → 5%: +1% per 1 ad\n'
                    '• 5% → 10%: +1% per 2 ads\n'
                    '• 10% → 15%: +1% per 4 ads\n'
                    '• 15% → 20%: +1% per 8 ads',
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This flow is now fixed by app logic and user-level Firebase fields.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminUserDiscountMonitor extends StatelessWidget {
  const _AdminUserDiscountMonitor({required this.controller});

  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isUserDiscountsLoading.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(
                'Loading user discount monitor...',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        );
      }

      final rows = controller.userDiscountRows.take(8).toList();
      if (rows.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            'No user discount data yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.6),
            ),
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Users', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 2),
            Text(
              'Discount + VIP status (latest 8 users)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            ...rows.map((u) => _UserRowTile(u: u, controller: controller)),
          ],
        ),
      );
    });
  }
}

class _UserRowTile extends StatelessWidget {
  const _UserRowTile({required this.u, required this.controller});

  final UserDiscountRow u;
  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    final vipActive = controller.isVipActive(u);
    final vipLabel = vipActive
        ? 'VIP${(u.vipType ?? '').toLowerCase() == 'yearly' ? ' · Yearly' : ''}'
        : (u.isVip ? 'Expired VIP' : 'Not VIP');
    final modeLabel =
        (!u.hasUsedWelcomeDiscount && u.hasReceivedWelcomeDiscount)
        ? 'Welcome'
        : 'Ad mode';
    final modeColor =
        (!u.hasUsedWelcomeDiscount && u.hasReceivedWelcomeDiscount)
        ? AppColors.accent
        : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  u.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: vipActive
                      ? AppColors.accent.withValues(alpha: 0.14)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  vipLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: vipActive
                        ? AppColors.accent
                        : AppColors.textDark.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${u.currentDiscountPercent.toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Ads: ${u.adsWatchedCount}',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 11),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  modeLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: modeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'UID: ${u.uid.length > 10 ? u.uid.substring(0, 10) : u.uid}…',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 10,
                  color: AppColors.textDark.withValues(alpha: 0.45),
                ),
              ),
              const Spacer(),
              Text(
                'Activation from Admin Profile',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 10,
                  color: AppColors.textDark.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
