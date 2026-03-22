import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/orders_controller.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/data/models/order.dart';
import '../../../../app/services/order_service.dart';
import '../../../../app/widgets/loading_overlay.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: Obx(
        () => LoadingOverlay(
          isLoading: controller.isUpdatingPaid.value ||
              controller.isUpdatingStatus.value,
          title: controller.isUpdatingPaid.value
              ? 'Updating payment'
              : (controller.isUpdatingStatus.value ? 'Updating order' : null),
          subtitle: controller.isUpdatingPaid.value ||
                  controller.isUpdatingStatus.value
              ? 'Syncing with your store…'
              : null,
          child: Container(
            color: AppColors.background,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _OrdersFiltersHeader(controller: controller),
                  ),
                  Expanded(
                    child: Obx(
                      () {
                        OrderService.to.orders.length;
                        controller.searchQuery.value;
                        controller.dateRange.value;
                        final allOrders = controller.orders;
                        final displayed = controller.displayedOrders;
                        final loading = OrderService.to.isOrdersLoading.value &&
                            allOrders.isEmpty;

                        Future<void> onRefresh() =>
                            OrderService.to.refreshOrdersFromServer();

                        if (loading) {
                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: onRefresh,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.55,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Loading orders...',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                            color: AppColors.textDark
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (allOrders.isEmpty) {
                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: onRefresh,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.55,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        'No orders yet.\nNew orders will appear here.',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textDark
                                              .withValues(alpha: 0.6),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (displayed.isEmpty) {
                          return RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: onRefresh,
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.55,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off_rounded,
                                            size: 48,
                                            color: AppColors.textDark
                                                .withValues(alpha: 0.35),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No orders match your filters',
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Try another keyword, or adjust the date range.',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              color: AppColors.textDark
                                                  .withValues(alpha: 0.55),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          FilledButton.tonal(
                                            onPressed:
                                                controller.clearAllFilters,
                                            child: const Text(
                                                'Clear search & date'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: onRefresh,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            itemCount: displayed.length,
                            itemBuilder: (_, i) {
                              return _OrderTile(order: displayed[i]);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrdersFiltersHeader extends StatelessWidget {
  final OrdersController controller;

  const _OrdersFiltersHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller.searchController,
          textInputAction: TextInputAction.search,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.black87,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Order ID, customer name, or email',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.45),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textDark.withValues(alpha: 0.55),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.textDark.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.textDark.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            suffixIcon: Obx(() {
              if (controller.searchQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Clear search',
                icon: Icon(
                  Icons.clear_rounded,
                  color: AppColors.textDark.withValues(alpha: 0.55),
                ),
                onPressed: controller.clearSearch,
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final r = controller.dateRange.value;
                return OutlinedButton.icon(
                  onPressed: controller.pickDateRange,
                  icon: const Icon(Icons.date_range_outlined, size: 18),
                  label: Text(
                    r == null
                        ? 'Filter by date'
                        : '${r.start.day}/${r.start.month}/${r.start.year} – ${r.end.day}/${r.end.month}/${r.end.year}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final hasFilter = controller.searchQuery.value.isNotEmpty ||
                  controller.dateRange.value != null;
              if (!hasFilter) return const SizedBox.shrink();
              return TextButton(
                onPressed: controller.clearAllFilters,
                child: const Text('Clear all'),
              );
            }),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Search: order ID, customer name, or email — partial text is fine. Use the date filter to show orders placed in that range.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    height: 1.35,
                    color: AppColors.textDark.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderTile extends GetView<OrdersController> {
  final Order order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: const Icon(Icons.receipt_long_outlined,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.customerName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PKR ${order.total.toStringAsFixed(0)} • ${order.items.length} item(s)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusChipSmall(status: order.status),
                  const SizedBox(height: 4),
                  _PaidChip(isPaid: order.isPaid),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ListView(
                controller: scrollController,
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
                  Text(
                    order.id,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        order.customerName,
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${order.customerEmail}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color:
                              AppColors.textDark.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusChipSmall(status: order.status),
                      const SizedBox(width: 8),
                      Text(
                        order.isCod ? 'Cash on delivery' : 'Bank transfer',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color:
                              AppColors.textDark.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PaidChip(isPaid: order.isPaid),
                    ],
                  ),
                  if (!order.isCod && order.paymentReceiptUrl != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(order.paymentReceiptUrl!);
                        if (uri == null) return;
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const Icon(Icons.receipt_long_outlined, size: 18),
                      label: const Text('View payment receipt'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Payment confirmation',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.isCod
                        ? 'COD: tap below when customer has paid on delivery.'
                        : 'Bank: confirm after you verify the transfer / receipt.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (!order.isPaid)
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => FilledButton.icon(
                          onPressed: controller.isUpdatingPaid.value
                              ? null
                              : () async {
                                  await controller.setOrderPaid(order, true);
                                  if (context.mounted) Navigator.pop(context);
                                },
                          icon: controller.isUpdatingPaid.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline, size: 20),
                          label: const Text('Confirm payment received'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => OutlinedButton.icon(
                          onPressed: controller.isUpdatingPaid.value
                              ? null
                              : () async {
                                  await controller.setOrderPaid(order, false);
                                  if (context.mounted) Navigator.pop(context);
                                },
                          icon: const Icon(Icons.undo, size: 18),
                          label: const Text('Mark as unpaid (mistake)'),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Items',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map(
                    (i) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        i.productName,
                        style: AppTextStyles.bodyMedium,
                      ),
                      subtitle: Text(
                        'Qty: ${i.quantity}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 11,
                          color: AppColors.textDark
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      trailing: Text(
                        'PKR ${i.lineTotal.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        'PKR ${order.total.toStringAsFixed(0)}',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Update status',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: OrderStatus.values.map((s) {
                      final isSelected = s == order.status;
                      return ChoiceChip(
                        label: Text(_statusLabel(s)),
                        selected: isSelected,
                        onSelected: (selected) async {
                          if (!selected) return;
                          await controller.updateStatus(order, s);
                          if (context.mounted) Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusChipSmall extends StatelessWidget {
  final OrderStatus status;

  const _StatusChipSmall({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: AppTextStyles.bodyMedium.copyWith(
          color: fg,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _PaidChip extends StatelessWidget {
  final bool isPaid;

  const _PaidChip({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    final bg = isPaid
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.danger.withValues(alpha: 0.08);
    final fg = isPaid ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Unpaid',
        style: AppTextStyles.bodyMedium.copyWith(
          color: fg,
          fontSize: 10,
        ),
      ),
    );
  }
}

String _statusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'Pending';
    case OrderStatus.packed:
      return 'Packed';
    case OrderStatus.shipped:
      return 'Shipped';
    case OrderStatus.delivered:
      return 'Delivered';
    case OrderStatus.cancelled:
      return 'Cancelled';
  }
}

(Color, Color) _colors(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return (
        AppColors.secondary.withValues(alpha: 0.12),
        AppColors.secondary
      );
    case OrderStatus.packed:
      return (
        AppColors.primary.withValues(alpha: 0.12),
        AppColors.primary
      );
    case OrderStatus.shipped:
      return (
        AppColors.accent.withValues(alpha: 0.12),
        AppColors.accent
      );
    case OrderStatus.delivered:
      return (
        AppColors.success.withValues(alpha: 0.12),
        AppColors.success
      );
    case OrderStatus.cancelled:
      return (
        AppColors.danger.withValues(alpha: 0.12),
        AppColors.danger
      );
  }
}

