import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_orders_controller.dart';
import '../../../../app/data/models/order.dart';
import '../../../../app/theme/app_colors.dart';
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
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark, size: 18),
          onPressed: () => Get.back(),
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
                  const Icon(Icons.filter_list_rounded,
                      color: AppColors.textDark),
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
      body: Obx(
        () {
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
        },
      ),
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
                        _sheetTile(
                          ctx,
                          'All orders',
                          null,
                          sel,
                        ),
                        _sheetTile(
                          ctx,
                          'Processing',
                          OrderStatus.pending,
                          sel,
                        ),
                        _sheetTile(
                          ctx,
                          'Packed',
                          OrderStatus.packed,
                          sel,
                        ),
                        _sheetTile(
                          ctx,
                          'Shipped',
                          OrderStatus.shipped,
                          sel,
                        ),
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
            Icon(Icons.shopping_bag_outlined,
                size: 64, color: AppColors.textDark.withValues(alpha: 0.2)),
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

  String get _dateStr {
    final d = order.createdAt;
    return '${d.day} ${_month(d.month)} ${d.year}';
  }

  String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '#MD-${order.id.length > 6 ? order.id.substring(0, 6) : order.id.toUpperCase()}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _statusColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: _statusColor, size: 15),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.water_drop_outlined,
                            size: 14, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item.productName} × ${item.quantity}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Divider(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.textDark.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _dateStr,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'PKR ${order.total.toStringAsFixed(0)}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
