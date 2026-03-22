import 'dart:async';

import 'package:get/get.dart';

import '../../../../app/services/auth_service.dart';
import '../../../../app/services/order_service.dart';
import '../../../../app/data/models/order.dart';

class UserOrdersController extends GetxController {
  final OrderService _orderService = OrderService.to;
  final AuthService _authService = AuthService.to;

  final orders = <Order>[].obs;
  final isLoading = true.obs;

  /// `null` = show all statuses.
  final statusFilter = Rxn<OrderStatus>();

  StreamSubscription<List<Order>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    ever(_authService.currentUser, (_) => _listenToUserOrders());
    _listenToUserOrders();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _listenToUserOrders() {
    _subscription?.cancel();
    final uid = _authService.currentUser.value?.uid;
    if (uid == null) {
      isLoading.value = false;
      orders.clear();
      return;
    }

    isLoading.value = true;
    _subscription = _orderService.userOrdersStream(uid).listen(
      (list) {
        // Newest first — backup sort (Firestore already orders desc).
        final sorted = List<Order>.from(list)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        orders.assignAll(sorted);
        isLoading.value = false;
      },
      onError: (_) => isLoading.value = false,
    );
  }

  void setStatusFilter(OrderStatus? status) {
    statusFilter.value = status;
  }

  /// Always newest at top, then optional status filter.
  List<Order> get displayOrders {
    final _ = orders.length;
    final filter = statusFilter.value;
    final list = List<Order>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (filter == null) return list;
    return list.where((o) => o.status == filter).toList();
  }

  bool get hasOrders => orders.isNotEmpty;

  /// Pull-to-refresh: one-shot fetch from server.
  Future<void> refreshOrders() async {
    final uid = _authService.currentUser.value?.uid;
    if (uid == null) return;
    try {
      final list = await _orderService.fetchUserOrdersOnce(uid);
      final sorted = List<Order>.from(list)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      orders.assignAll(sorted);
    } catch (_) {}
  }
}
