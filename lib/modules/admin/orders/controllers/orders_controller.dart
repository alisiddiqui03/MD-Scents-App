import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/services/order_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/data/models/order.dart';
import '../../../../app/utils/admin_snackbar.dart';
import '../../../../app/utils/order_action_time.dart';

class OrdersController extends GetxController {
  final OrderService _orderService = OrderService.to;

  final isUpdatingPaid = false.obs;
  final isUpdatingStatus = false.obs;
  final isCancellingOrder = false.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final dateRange = Rx<DateTimeRange?>(null);

  final statusFilter = Rxn<OrderStatus>();

  List<Order> get orders => _orderService.orders;

  List<Order> get displayedOrders {
    final all = List<Order>.from(_orderService.orders);
    final q = searchQuery.value.trim().toLowerCase();
    Iterable<Order> iter = all;
    if (q.isNotEmpty) {
      iter = iter.where((o) {
        final phone = o.deliveryPhone.toLowerCase();
        return o.id.toLowerCase().contains(q) ||
            o.customerName.toLowerCase().contains(q) ||
            o.customerEmail.toLowerCase().contains(q) ||
            phone.contains(q);
      });
    }
    final range = dateRange.value;
    if (range != null) {
      final start = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final end = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
        59,
      );
      iter = iter.where((o) {
        final d = o.createdAt;
        return !d.isBefore(start) && !d.isAfter(end);
      });
    }
    final status = statusFilter.value;
    if (status != null) {
      iter = iter.where((o) => o.status == status);
    }
    final list = iter.toList();
    if (status == null) {
      list.sort((a, b) {
        final c = _statusRank(a.status).compareTo(_statusRank(b.status));
        if (c != 0) return c;
        return b.createdAt.compareTo(a.createdAt);
      });
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  static int _statusRank(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.packed:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return 4;
    }
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void clearDateFilter() {
    dateRange.value = null;
  }

  void clearAllFilters() {
    clearSearch();
    clearDateFilter();
    statusFilter.value = null;
  }

  void setStatusFilter(OrderStatus? status) {
    statusFilter.value = status;
  }

  Future<void> pickDateRange() async {
    final ctx = Get.context;
    if (ctx == null) return;
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: ctx,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange:
          dateRange.value ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      dateRange.value = picked;
      AdminSnackbar.info(
        'Date filter applied',
        '${_fmt(picked.start)} → ${_fmt(picked.end)}',
      );
    }
  }

  static String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> updateStatus(Order order, OrderStatus status) async {
    isUpdatingStatus.value = true;
    try {
      await _orderService.updateStatus(order, status);
      AdminSnackbar.success(
        'Order updated',
        'Status: ${_statusLabel(status)} · ${formatOrderActionTime()}',
      );
    } catch (e) {
      AdminSnackbar.error('Could not update', e.toString());
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  Future<void> setOrderPaid(Order order, bool isPaid) async {
    if (order.firestorePath == null) return;
    isUpdatingPaid.value = true;
    try {
      await _orderService.updatePaidStatus(order, isPaid);
      AdminSnackbar.success(
        isPaid ? 'Payment confirmed' : 'Marked as unpaid',
        isPaid
            ? 'Marked as paid · ${formatOrderActionTime()}'
            : 'Marked unpaid · ${formatOrderActionTime()}',
      );
    } catch (e) {
      AdminSnackbar.error('Update failed', e.toString());
    } finally {
      isUpdatingPaid.value = false;
    }
  }

  Future<void> cancelOrderWithReason(Order order, String reason) async {
    final trimmed = reason.trim();
    if (trimmed.isEmpty) {
      AdminSnackbar.error(
        'Reason required',
        'Enter a cancellation reason so the customer knows why.',
      );
      return;
    }
    isCancellingOrder.value = true;
    try {
      await _orderService.cancelOrderWithReason(order, trimmed);
      AdminSnackbar.success(
        'Order cancelled',
        'Customer notified · ${formatOrderActionTime()}',
      );
    } catch (e) {
      AdminSnackbar.error('Could not cancel', e.toString());
      rethrow;
    } finally {
      isCancellingOrder.value = false;
    }
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
