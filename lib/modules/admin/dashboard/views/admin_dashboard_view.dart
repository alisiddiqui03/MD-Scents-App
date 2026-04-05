import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

import '../controllers/admin_dashboard_controller.dart';
import '../../../../app/services/admin_referrals_service.dart';
import '../../../../app/services/order_service.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/utils/order_action_time.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFE0F2FE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _DashboardHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _KpiRow(controller: controller),
                      const SizedBox(height: 16),
                      _AdsDiscountEntryCard(),
                      // const SizedBox(height: 20),
                      // const _ReferralsAdminCard(),
                      const SizedBox(height: 20),
                      _StatusSummary(controller: controller),
                      const SizedBox(height: 20),
                      _QuickInsights(controller: controller),
                      const SizedBox(height: 20),
                      _SalesChartsSection(controller: controller),
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

/// Admin: opens ads flow + user discount monitor (same as Profile → Ads & user discounts).
class _AdsDiscountEntryCard extends StatelessWidget {
  const _AdsDiscountEntryCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.ADMIN_ADS_DISCOUNT),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: AppColors.secondary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ads & user discounts',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ad flow rules & user discount monitor',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.55),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textDark.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SalesChartsSection extends StatelessWidget {
  final AdminDashboardController controller;

  const _SalesChartsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Subscribe to order stream updates
      OrderService.to.orders.length;
      final revenue = controller.revenueLast7Days;
      final labels = controller.last7DayLabels;
      final maxY = _chartMaxY(revenue);
      final cod = controller.codOrders.toDouble();
      final bank = controller.bankOrders.toDouble();
      final totalPay = cod + bank;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales & payments',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                  'Revenue (last 7 days)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY > 0 ? maxY / 4 : 250,
                        getDrawingHorizontalLine: (v) =>
                            FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (v, m) => Text(
                              v >= 1000
                                  ? '${(v / 1000).toStringAsFixed(1)}k'
                                  : v.toInt().toString(),
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, m) {
                              final i = v.toInt();
                              if (i < 0 || i >= labels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  labels[i],
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: i < revenue.length ? revenue[i] : 0,
                              width: 14,
                              borderRadius: BorderRadius.circular(6),
                              color: AppColors.primary,
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                  'Payment method mix',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (totalPay <= 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No orders yet — chart will fill when orders arrive.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 44,
                              sections: [
                                PieChartSectionData(
                                  value: cod,
                                  title: cod > 0 ? 'COD\n${cod.toInt()}' : '',
                                  color: AppColors.secondary,
                                  radius: 52,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: bank,
                                  title: bank > 0
                                      ? 'Bank\n${bank.toInt()}'
                                      : '',
                                  color: AppColors.accent,
                                  radius: 52,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LegendDot(
                              color: AppColors.secondary,
                              label: 'COD',
                              value: controller.codOrders.toString(),
                            ),
                            const SizedBox(height: 10),
                            _LegendDot(
                              color: AppColors.accent,
                              label: 'Bank transfer',
                              value: controller.bankOrders.toString(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Paid (proof): ${controller.paidOrders}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 11,
                                color: AppColors.textDark.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }

  static double _chartMaxY(List<double> revenue) {
    final m = revenue.fold<double>(0, (a, b) => a > b ? a : b);
    if (m <= 0) return 1000;
    return m * 1.15;
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MD SCENTS',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Admin dashboard',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_moon_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Admin',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final AdminDashboardController controller;

  const _KpiRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Total sales',
                valueBuilder: () =>
                    'PKR ${controller.totalSales.toStringAsFixed(0)}',
                icon: Icons.payments_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                label: 'Total orders',
                valueBuilder: () => controller.totalOrders.toString(),
                icon: Icons.receipt_long_outlined,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TotalProductsCard(controller: controller),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String Function() valueBuilder;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.valueBuilder,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    valueBuilder(),
                    style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalProductsCard extends StatelessWidget {
  final AdminDashboardController controller;

  const _TotalProductsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total products',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.totalProducts.toString(),
                    style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: AppColors.success.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Text(
                  'Live in store',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textDark.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSummary extends StatelessWidget {
  final AdminDashboardController controller;

  const _StatusSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Order pipeline',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusChip(
                  label: 'Pending',
                  count: controller.pendingOrders,
                  color: AppColors.secondary,
                ),
                _StatusChip(
                  label: 'Shipped',
                  count: controller.shippedOrders,
                  color: AppColors.primary,
                ),
                _StatusChip(
                  label: 'Delivered',
                  count: controller.deliveredOrders,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickInsights extends StatelessWidget {
  final AdminDashboardController controller;

  const _QuickInsights({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      ProductService.to.productsVersion.value;
      ProductService.to.lowStockThreshold.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              'Quick insights',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _InsightChip(
                  icon: Icons.inventory_2_outlined,
                  label: 'Low stock products',
                  value: controller.lowStockCount.toString(),
                ),
                const SizedBox(width: 8),
                _InsightChip(
                  icon: Icons.warning_amber_outlined,
                  label: 'Unpaid orders',
                  value: controller.unpaidOrders.toString(),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _InsightChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InsightChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11,
                      color: AppColors.textDark.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.titleLarge.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: AppTextStyles.headlineMedium.copyWith(
            color: color,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Recent referral rows (referrer → referred user, pending vs completed).
class _ReferralsAdminCard extends StatelessWidget {
  const _ReferralsAdminCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      AdminReferralsService.to.rows.length;
      AdminReferralsService.to.isLoading.value;
      final rows = AdminReferralsService.to.rows;
      final loading = AdminReferralsService.to.isLoading.value;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.ADMIN_REFERRALS),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Referrals',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to open the full list, filter by date, and view each referral order in detail.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.textDark.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (loading && rows.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (rows.isEmpty)
                    Text(
                      'No referral activity yet.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.45),
                        fontSize: 13,
                      ),
                    )
                  else
                    Column(
                      children: rows.take(6).map((r) {
                        final st = r.status == 'completed'
                            ? 'Completed'
                            : 'Pending';
                        final c = r.status == 'completed'
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFF59E0B);
                        final invitedName =
                            (r.referredUserName != null &&
                                r.referredUserName!.trim().isNotEmpty)
                            ? r.referredUserName!.trim()
                            : 'User ${r.referredUserId.length > 8 ? r.referredUserId.substring(0, 8) : r.referredUserId}…';
                        final invitedEmail =
                            (r.referredUserEmail != null &&
                                r.referredUserEmail!.trim().isNotEmpty)
                            ? r.referredUserEmail!.trim()
                            : null;
                        final orderShort = r.orderId.length > 12
                            ? '${r.orderId.substring(0, 12)}…'
                            : r.orderId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.textDark.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.textDark.withValues(
                                  alpha: 0.06,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Invited: $invitedName',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w800,
                                                  height: 1.25,
                                                ),
                                          ),
                                          if (invitedEmail != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              invitedEmail,
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                    fontSize: 11,
                                                    color: AppColors.textDark
                                                        .withValues(
                                                          alpha: 0.65,
                                                        ),
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: c.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        st,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: c,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Reward PKR ${r.rewardAmount.toStringAsFixed(0)} · Order $orderShort',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 10,
                                    color: AppColors.textDark.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                                ),
                                if (r.createdAt != null)
                                  Text(
                                    'Created: ${formatOrderActionTime(r.createdAt)}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 10,
                                      color: AppColors.textDark.withValues(
                                        alpha: 0.45,
                                      ),
                                    ),
                                  ),
                                if (r.completedAt != null)
                                  Text(
                                    'Completed: ${formatOrderActionTime(r.completedAt)}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  'Referrer UID: ${r.referrerUid.length > 10 ? r.referrerUid.substring(0, 10) : r.referrerUid}…',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 9,
                                    color: AppColors.textDark.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap for orders → mark Delivered + Paid to activate rewards',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11,
                      color: AppColors.primary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
