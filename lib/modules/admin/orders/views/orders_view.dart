import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/services/order_service.dart';

import '../controllers/orders_controller.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/data/models/order.dart';
import '../../../../app/utils/order_action_time.dart';
import '../../../../app/widgets/loading_overlay.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          Obx(() {
            final n = OrderService.to.orders
                .where((o) => o.status == OrderStatus.cancelled)
                .length;
            if (n == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton.icon(
                onPressed: controller.confirmDeleteAllCancelled,
                icon: Icon(
                  Icons.delete_sweep_outlined,
                  size: 20,
                  color: AppColors.danger.withValues(alpha: 0.9),
                ),
                label: Text(
                  'Clear cancelled ($n)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger.withValues(alpha: 0.95),
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(
        () => LoadingOverlay(
          isLoading:
              controller.isUpdatingPaid.value ||
              controller.isUpdatingStatus.value ||
              controller.isCancellingOrder.value ||
              controller.isDeletingOrder.value,
          title: controller.isCancellingOrder.value
              ? 'Cancelling order'
              : controller.isDeletingOrder.value
              ? 'Removing order(s)'
              : (controller.isUpdatingPaid.value
                    ? 'Updating payment'
                    : (controller.isUpdatingStatus.value
                          ? 'Updating order'
                          : null)),
          subtitle:
              controller.isUpdatingPaid.value ||
                  controller.isUpdatingStatus.value ||
                  controller.isCancellingOrder.value ||
                  controller.isDeletingOrder.value
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
                    child: Obx(() {
                      OrderService.to.orders.length;
                      controller.searchQuery.value;
                      controller.dateRange.value;
                      controller.statusFilter.value;
                      final allOrders = controller.orders;
                      final displayed = controller.displayedOrders;
                      final loading =
                          OrderService.to.isOrdersLoading.value &&
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        color: AppColors.textDark.withValues(
                                          alpha: 0.6,
                                        ),
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
                                          color: AppColors.textDark.withValues(
                                            alpha: 0.35,
                                          ),
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
                                          onPressed: controller.clearAllFilters,
                                          child: const Text(
                                            'Clear search & date',
                                          ),
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
                    }),
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
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Order ID, name, email, or phone',
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
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
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
              final hasFilter =
                  controller.searchQuery.value.isNotEmpty ||
                  controller.dateRange.value != null ||
                  controller.statusFilter.value != null;
              if (!hasFilter) return const SizedBox.shrink();
              return TextButton(
                onPressed: controller.clearAllFilters,
                child: const Text('Clear all'),
              );
            }),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Obx(() {
            final selected = controller.statusFilter.value;
            return Row(
              children: [
                _StatusFilterChip(
                  label: 'All',
                  selected: selected == null,
                  onTap: () => controller.setStatusFilter(null),
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Pending',
                  selected: selected == OrderStatus.pending,
                  onTap: () => controller.setStatusFilter(OrderStatus.pending),
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Packed',
                  selected: selected == OrderStatus.packed,
                  onTap: () => controller.setStatusFilter(OrderStatus.packed),
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Shipped',
                  selected: selected == OrderStatus.shipped,
                  onTap: () => controller.setStatusFilter(OrderStatus.shipped),
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Delivered',
                  selected: selected == OrderStatus.delivered,
                  onTap: () =>
                      controller.setStatusFilter(OrderStatus.delivered),
                ),
                const SizedBox(width: 8),
                _StatusFilterChip(
                  label: 'Cancelled',
                  selected: selected == OrderStatus.cancelled,
                  onTap: () =>
                      controller.setStatusFilter(OrderStatus.cancelled),
                ),
              ],
            );
          }),
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
                  'Search by order ID, name, email, or phone. Use status chips to focus pending vs delivered. Date filter limits by order date.',
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

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.12)
          : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textDark,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderTile extends GetView<OrdersController> {
  final Order order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final card = Card(
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
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.customerName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.customerEmail.isNotEmpty
                          ? order.customerEmail
                          : '—',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (order.deliveryPhone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        order.deliveryPhone,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.55),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'PKR ${order.total.toStringAsFixed(0)} • ${order.items.length} item(s)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppColors.textDark.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Placed ${formatOrderActionTime(order.createdAt)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textDark.withValues(alpha: 0.45),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (order.status == OrderStatus.cancelled) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Swipe right → to delete',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textDark.withValues(alpha: 0.38),
                        ),
                      ),
                    ],
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

    if (order.status != OrderStatus.cancelled) {
      return card;
    }

    return Dismissible(
      key: ValueKey('adm-del-${order.firestorePath ?? order.id}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        final ok = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete cancelled order?'),
            content: Text(
              'Remove this order from the admin list permanently. This cannot be undone.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                color: AppColors.textDark.withValues(alpha: 0.75),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (ok != true) return false;
        return controller.tryDeleteCancelledOrder(order);
      },
      child: card,
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      // Use this context for Navigator.pop after async work. Popping the parent
      // (OrdersView) context stays mounted after the sheet closes and a second
      // pop removes /admin — black screen.
      builder: (sheetContext) {
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
                  Text(order.id, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.textDark.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Placed ${formatOrderActionTime(order.createdAt)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.customerName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.customerEmail.isNotEmpty ? order.customerEmail : '—',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.75),
                      fontSize: 13,
                    ),
                  ),
                  if (order.deliveryPhone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: AppColors.textDark.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.deliveryPhone,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Delivery address',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.deliverySummaryLine.isNotEmpty
                        ? order.deliverySummaryLine
                        : (order.deliveryStreet.isNotEmpty
                              ? order.deliveryStreet
                              : '—'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.75),
                      fontSize: 13,
                    ),
                  ),
                  if (order.referralFreeDelivery) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Free delivery (referral)',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (order.referredBy != null &&
                      order.referredBy!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Referral',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Referrer user ID: ${order.referredBy}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        color: AppColors.textDark.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reward status: ${order.referralStatusLabel}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                  if (order.status == OrderStatus.cancelled &&
                      (order.cancellationReason?.trim().isNotEmpty ??
                          false)) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cancellation reason',
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
                              height: 1.35,
                            ),
                          ),
                          if (order.cancelledAt != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _fmtCancelled(order.cancelledAt!),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 11,
                                color: AppColors.textDark.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatusChipSmall(status: order.status),
                      const SizedBox(width: 8),
                      Text(
                        order.isCod ? 'Cash on delivery' : 'Bank transfer',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.6),
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
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
                        () {
                          final busy = controller.isUpdatingPaid.value ||
                              controller.isUpdatingStatus.value;
                          return FilledButton.icon(
                            onPressed: busy
                                ? null
                                : () async {
                                    await controller.setOrderPaid(order, true);
                                    if (sheetContext.mounted) {
                                      Navigator.of(sheetContext).pop();
                                    }
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
                                : const Icon(
                                    Icons.check_circle_outline,
                                    size: 20,
                                  ),
                            label: const Text('Confirm payment received'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () {
                          final busy = controller.isUpdatingPaid.value ||
                              controller.isUpdatingStatus.value;
                          return OutlinedButton.icon(
                            onPressed: busy
                                ? null
                                : () async {
                                    await controller.setOrderPaid(order, false);
                                    if (sheetContext.mounted) {
                                      Navigator.of(sheetContext).pop();
                                    }
                                  },
                            icon: const Icon(Icons.undo, size: 18),
                            label: const Text('Mark as unpaid (mistake)'),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Items',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
                          color: AppColors.textDark.withValues(alpha: 0.6),
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
                  if (order.bankTransferDiscountAmount > 0.009) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bank transfer discount (5%)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textDark.withValues(alpha: 0.65),
                          ),
                        ),
                        Text(
                          '− PKR ${order.bankTransferDiscountAmount.toStringAsFixed(0)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.bodyMedium),
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
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final busy = controller.isUpdatingPaid.value ||
                        controller.isUpdatingStatus.value;
                    return Wrap(
                      spacing: 8,
                      children: OrderStatus.values
                          .where((s) => s != OrderStatus.cancelled)
                          .map((s) {
                            final isSelected = s == order.status;
                            return ChoiceChip(
                              label: Text(_statusLabel(s)),
                              selected: isSelected,
                              onSelected: busy
                                  ? null
                                  : (selected) async {
                                      if (!selected) return;
                                      await controller.updateStatus(order, s);
                                      if (sheetContext.mounted) {
                                        Navigator.of(sheetContext).pop();
                                      }
                                    },
                            );
                          })
                          .toList(),
                    );
                  }),
                  if (order.status != OrderStatus.cancelled) ...[
                    const SizedBox(height: 12),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.isCancellingOrder.value ||
                                  controller.isUpdatingPaid.value ||
                                  controller.isUpdatingStatus.value
                              ? null
                              : () => _promptCancelOrder(sheetContext, order),
                          icon: const Icon(Icons.cancel_outlined, size: 20),
                          label: const Text('Cancel order'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: BorderSide(
                              color: AppColors.danger.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _promptCancelOrder(BuildContext context, Order order) async {
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel order'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'The customer will see this reason in the app and in order history. '
                  'You must enter a reason — it cannot be empty.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonCtrl,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    labelText: 'Cancellation reason *',
                    hintText: 'e.g. Item out of stock',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.75),
                    ),
                    floatingLabelStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.38),
                    ),
                    errorStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.danger),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.danger),
                    ),
                  ),
                  maxLines: 4,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a reason — the customer will read this.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Back'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(ctx, true);
            },
            child: const Text('Confirm cancel'),
          ),
        ],
      ),
    );
    try {
      if (ok == true) {
        await controller.cancelOrderWithReason(order, reasonCtrl.text.trim());
        // [context] is the modal sheet context — pop only the sheet, not /admin.
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } finally {
      reasonCtrl.dispose();
    }
  }
}

String _fmtCancelled(DateTime d) =>
    'Cancelled ${d.day}/${d.month}/${d.year} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

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
        style: AppTextStyles.bodyMedium.copyWith(color: fg, fontSize: 10),
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
        style: AppTextStyles.bodyMedium.copyWith(color: fg, fontSize: 10),
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
      return (AppColors.secondary.withValues(alpha: 0.12), AppColors.secondary);
    case OrderStatus.packed:
      return (AppColors.primary.withValues(alpha: 0.12), AppColors.primary);
    case OrderStatus.shipped:
      return (AppColors.accent.withValues(alpha: 0.12), AppColors.accent);
    case OrderStatus.delivered:
      return (AppColors.success.withValues(alpha: 0.12), AppColors.success);
    case OrderStatus.cancelled:
      return (AppColors.danger.withValues(alpha: 0.12), AppColors.danger);
  }
}
