import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_orders_controller.dart';
import '../../../../app/data/models/order.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/utils/order_action_time.dart';
import '../../../../app/theme/app_text_styles.dart';

class OrdersView extends GetView<UserOrdersController> {
  const OrdersView({super.key});

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
          onPressed: () async {
            if (Get.isSnackbarOpen) {
              await Get.closeCurrentSnackbar();
            }
            Get.back();
          },
        ),
        title: Text(
          'MY ORDERS',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            final hasFilter = controller.statusFilter.value != null;
            return IconButton(
              tooltip: 'Filter by status',
              onPressed: () => _showFilterSheet(context),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.textDark,
                  ),
                  if (hasFilter)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        Future<void> onRefresh() => controller.refreshOrders();

        if (controller.isLoading.value) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.45,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }
        if (!controller.hasOrders) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.65,
                  child: _buildEmpty(all: true),
                ),
              ],
            ),
          );
        }

        final display = controller.displayOrders;
        if (display.isEmpty) {
          return Column(
            children: [
              _buildStatusChips(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.45,
                        child: _buildEmpty(all: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusChips(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: onRefresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: display.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _OrderCard(order: display[i]),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatusChips() {
    return Obx(() {
      final selected = controller.statusFilter.value;
      return Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: selected == null,
                onTap: () => controller.setStatusFilter(null),
              ),
              _FilterChip(
                label: 'Processing',
                selected: selected == OrderStatus.pending,
                onTap: () => controller.setStatusFilter(OrderStatus.pending),
              ),
              _FilterChip(
                label: 'Packed',
                selected: selected == OrderStatus.packed,
                onTap: () => controller.setStatusFilter(OrderStatus.packed),
              ),
              _FilterChip(
                label: 'Shipped',
                selected: selected == OrderStatus.shipped,
                onTap: () => controller.setStatusFilter(OrderStatus.shipped),
              ),
              _FilterChip(
                label: 'Delivered',
                selected: selected == OrderStatus.delivered,
                onTap: () => controller.setStatusFilter(OrderStatus.delivered),
              ),
              _FilterChip(
                label: 'Cancelled',
                selected: selected == OrderStatus.cancelled,
                onTap: () => controller.setStatusFilter(OrderStatus.cancelled),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Filter by status',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final sel = controller.statusFilter.value;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _sheetTile(ctx, 'All orders', null, sel),
                        _sheetTile(ctx, 'Processing', OrderStatus.pending, sel),
                        _sheetTile(ctx, 'Packed', OrderStatus.packed, sel),
                        _sheetTile(ctx, 'Shipped', OrderStatus.shipped, sel),
                        _sheetTile(
                          ctx,
                          'Delivered',
                          OrderStatus.delivered,
                          sel,
                        ),
                        _sheetTile(
                          ctx,
                          'Cancelled',
                          OrderStatus.cancelled,
                          sel,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sheetTile(
    BuildContext context,
    String label,
    OrderStatus? value,
    OrderStatus? current,
  ) {
    final selected = value == current;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.primary : AppColors.textDark,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: AppColors.primary, size: 22)
          : null,
      onTap: () {
        controller.setStatusFilter(value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEmpty({required bool all}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.textDark.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              all ? 'No orders yet' : 'No orders in this filter',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              all
                  ? 'Your order history will appear here.'
                  : 'Try another status or tap “All”.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? Colors.white : AppColors.textDark,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.shipped:
      case OrderStatus.packed:
        return AppColors.secondary;
      case OrderStatus.pending:
        return AppColors.accent;
      case OrderStatus.cancelled:
        return AppColors.danger;
    }
  }

  IconData get _statusIcon {
    switch (order.status) {
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.shipped:
      case OrderStatus.packed:
        return Icons.local_shipping_outlined;
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String get _statusLabel {
    switch (order.status) {
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.pending:
        return 'Processing';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static TextStyle _labelStyle() => AppTextStyles.bodyMedium.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.textDark.withValues(alpha: 0.45),
      );

  static TextStyle _valueStyle() => AppTextStyles.bodyMedium.copyWith(
        fontSize: 14,
        height: 1.35,
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
      );

  @override
  Widget build(BuildContext context) {
    final displayId =
        '#MD-${order.id.length > 6 ? order.id.substring(0, 6) : order.id.toUpperCase()}';
    final name = order.customerName.trim();
    final email = order.customerEmail.trim();
    final itemCount = order.items.fold<int>(0, (a, i) => a + i.quantity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header: order id + status ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.09),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDER ID',
                        style: _labelStyle(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayId,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontSize: 16,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _statusColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: _statusColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _statusLabel,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Contact ─────────────────────────────────────────────────
                Text('NAME', style: _labelStyle()),
                const SizedBox(height: 4),
                Text(
                  name.isNotEmpty ? name : '—',
                  style: _valueStyle(),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('EMAIL', style: _labelStyle()),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textDark.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                const SizedBox(height: 14),

                // ── Items ───────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ITEMS',
                      style: _labelStyle(),
                    ),
                    Text(
                      '$itemCount ${itemCount == 1 ? 'piece' : 'pieces'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.spa_outlined,
                          size: 14,
                          color: AppColors.secondary.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '× ${item.quantity}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (order.status == OrderStatus.cancelled &&
                    (order.cancellationReason?.trim().isNotEmpty ?? false)) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancelled by store',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.cancellationReason!.trim(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        if (order.cancelledAt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Cancelled · ${formatOrderActionTime(order.cancelledAt)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 11,
                              color: AppColors.textDark.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ORDERED ON',
                              style: _labelStyle(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatOrderActionTime(order.createdAt),
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textDark,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 52,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TOTAL',
                              style: _labelStyle(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'PKR ${order.total.toStringAsFixed(0)}',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
