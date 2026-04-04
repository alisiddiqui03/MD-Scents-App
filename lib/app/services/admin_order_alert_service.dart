import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'auth_service.dart';
import 'order_service.dart';
import '../utils/admin_snackbar.dart';
import '../utils/get_snackbar_surface.dart';

class AdminOrderAlertService extends GetxService {
  AdminOrderAlertService();

  static AdminOrderAlertService get to => Get.find<AdminOrderAlertService>();

  static const _storageKey = 'admin_orders_seen_max_ms';

  final unseenOrderCount = 0.obs;

  int? _lastSeenMaxMs;
  int _prevUnseen = 0;

  @override
  void onInit() {
    super.onInit();
    _lastSeenMaxMs = GetStorage().read<int>(_storageKey);
    ever(OrderService.to.ordersRx, (_) => _recompute());
    ever(AuthService.to.currentUser, (_) => _recompute());
    _recompute();
  }

  void _recompute() {
    if (!AuthService.to.isAdmin) {
      unseenOrderCount.value = 0;
      _prevUnseen = 0;
      return;
    }

    final orders = OrderService.to.orders;
    if (orders.isEmpty) {
      unseenOrderCount.value = 0;
      _prevUnseen = 0;
      return;
    }

    final maxMs = orders
        .map((o) => o.createdAt.millisecondsSinceEpoch)
        .reduce(math.max);

    if (_lastSeenMaxMs == null) {
      _lastSeenMaxMs = maxMs;
      GetStorage().write(_storageKey, _lastSeenMaxMs);
      unseenOrderCount.value = 0;
      _prevUnseen = 0;
      return;
    }

    final n = orders
        .where((o) => o.createdAt.millisecondsSinceEpoch > _lastSeenMaxMs!)
        .length;
    unseenOrderCount.value = n;

    if (_prevUnseen == 0 && n > 0) {
      Future.microtask(() => _showNewOrderSnackbarAsync(n));
    }
    _prevUnseen = n;
  }

  /// Same overlay retry as [UserOrderStreamService] — release-safe new-order alert.
  Future<void> _showNewOrderSnackbarAsync(int count) async {
    if (count <= 0) return;
    await runWhenSnackbarSurfaceReady(
      (skipOverlayGuard) => _showNewOrderSnackbarBody(
        count,
        skipOverlayGuard: skipOverlayGuard,
      ),
      shouldAbort: () => !AuthService.to.isAdmin,
    );
  }

  void _showNewOrderSnackbarBody(int n, {required bool skipOverlayGuard}) {
    if (!AuthService.to.isAdmin) return;
    if (!skipOverlayGuard && !getSnackbarSurfaceReady()) return;
    AdminSnackbar.newOrderAlert(n);
  }

  void acknowledgeSeenOrders() {
    if (!AuthService.to.isAdmin) return;
    final orders = OrderService.to.orders;
    if (orders.isEmpty) return;
    final maxMs = orders
        .map((o) => o.createdAt.millisecondsSinceEpoch)
        .reduce(math.max);
    _lastSeenMaxMs = maxMs;
    GetStorage().write(_storageKey, maxMs);
    unseenOrderCount.value = 0;
    _prevUnseen = 0;
  }
}
