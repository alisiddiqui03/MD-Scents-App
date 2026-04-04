import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_service.dart';
import 'order_service.dart';
import '../data/models/order.dart';
import '../theme/app_colors.dart';
import '../utils/get_snackbar_surface.dart';
import '../utils/order_action_time.dart';

/// Listens to the signed-in user's orders for [My Orders] data and shows
/// cancellation snackbars on **any** screen (not only when My Orders is open).
/// Registered in [main] so it starts as soon as auth is ready.
class UserOrderStreamService extends GetxService {
  UserOrderStreamService();

  static UserOrderStreamService get to => Get.find<UserOrderStreamService>();

  final OrderService _orderService = OrderService.to;
  final AuthService _authService = AuthService.to;

  final orders = <Order>[].obs;
  final isLoading = true.obs;

  StreamSubscription<List<Order>>? _subscription;

  /// Serialize cancellation snackbar + mark-read so rapid Firestore snapshots
  /// cannot show duplicate snackbars or race mark-read.
  Future<void> _cancellationPipeline = Future<void>.value();

  /// Snackbar only for cancellations that occur after this session (login / listener start).
  late DateTime _sessionStart;
  String? _boundUid;

  @override
  void onInit() {
    super.onInit();
    _sessionStart = DateTime.now();
    ever(_authService.currentUser, (_) => _listenToUserOrders());
    ever(_authService.firebaseUser, (_) => _listenToUserOrders());
    _listenToUserOrders();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _listenToUserOrders() {
    _subscription?.cancel();
    final uid = _authService.currentUser.value?.uid ??
        _authService.firebaseUser.value?.uid;
    if (uid == null) {
      _boundUid = null;
      if (!isClosed) {
        isLoading.value = false;
        orders.clear();
      }
      return;
    }

    if (_boundUid != uid) {
      _boundUid = uid;
      _sessionStart = DateTime.now();
    }

    if (!isClosed) isLoading.value = true;
    _subscription = _orderService.userOrdersStream(uid).listen(
      (list) {
        if (isClosed) return;
        final sorted = List<Order>.from(list)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        orders.assignAll(sorted);
        isLoading.value = false;
        _cancellationPipeline = _cancellationPipeline.then((_) async {
          try {
            await _showCancellationNoticesIfNeeded(uid, sorted);
          } catch (_) {}
        });
      },
      onError: (_) {
        if (!isClosed) isLoading.value = false;
      },
    );
  }

  Future<void> _showCancellationNoticesIfNeeded(
    String uid,
    List<Order> list,
  ) async {
    if (isClosed) return;
    final activeUid = _authService.firebaseUser.value?.uid ??
        _authService.currentUser.value?.uid;
    if (activeUid != uid) return;

    final rawUnread = list
        .where(
          (o) =>
              o.status == OrderStatus.cancelled &&
              o.cancellationUnreadForUser &&
              (o.cancellationReason?.trim().isNotEmpty ?? false),
        )
        .toList();
    if (rawUnread.isEmpty) return;

    const slack = Duration(seconds: 30);
    final cutoff = _sessionStart.subtract(slack);

    final fresh = rawUnread.where((o) {
      final ca = o.cancelledAt;
      if (ca == null) return false;
      return ca.isAfter(cutoff);
    }).toList();

    if (fresh.isEmpty) {
      final hasPendingCancelledAt =
          rawUnread.any((o) => o.cancelledAt == null);
      if (hasPendingCancelledAt) return;
      try {
        if (!isClosed) {
          await _orderService.markCancellationNoticesReadForUser(uid);
        }
      } catch (_) {}
      return;
    }

    if (fresh.length == 1) {
      final o = fresh.first;
      await _snackbarCancellationSafe(
        'Order cancelled',
        '${_orderDisplayId(o.id)} · ${formatOrderActionTime(o.cancelledAt)} · '
        'See My Orders for details.',
        const Duration(seconds: 4),
      );
    } else {
      await _snackbarCancellationSafe(
        'Orders cancelled',
        '${fresh.length} orders · ${formatOrderActionTime()} · '
        'See My Orders for details.',
        const Duration(seconds: 4),
      );
    }

    try {
      if (!isClosed) {
        await _orderService.markCancellationNoticesReadForUser(uid);
      }
    } catch (_) {}
  }

  Future<void> _snackbarCancellationSafe(
    String title,
    String message,
    Duration dur,
  ) async {
    await runWhenSnackbarSurfaceReady(
      (skipOverlayGuard) => _snackbarCancellationBody(
        title,
        message,
        dur,
        requireOverlay: !skipOverlayGuard,
      ),
      shouldAbort: () => isClosed,
    );
  }

  void _snackbarCancellationBody(
    String title,
    String message,
    Duration dur, {
    bool requireOverlay = true,
  }) {
    if (isClosed) return;
    if (requireOverlay && !getSnackbarSurfaceReady()) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      duration: dur,
      icon: const Icon(Icons.cancel_outlined, color: Colors.white),
      maxWidth: 420,
      barBlur: 0,
    );
  }

  String _orderDisplayId(String id) =>
      id.length > 6 ? '#MD-${id.substring(0, 6).toUpperCase()}' : id;

  Future<void> refreshOrders() async {
    final uid = _authService.currentUser.value?.uid ??
        _authService.firebaseUser.value?.uid;
    if (uid == null) return;
    try {
      final list = await _orderService.fetchUserOrdersOnce(uid);
      if (isClosed) return;
      final sorted = List<Order>.from(list)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      orders.assignAll(sorted);
    } catch (_) {}
  }
}
