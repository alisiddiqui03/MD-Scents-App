import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../services/onesignal_service.dart';
import '../config/referral_constants.dart';
import '../data/models/order.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// Order data + admin-facing helpers backed by Firestore.
class OrderService extends GetxService {
  OrderService();

  static OrderService get to => Get.find<OrderService>();

  final _orders = <Order>[].obs;

  /// True until first orders snapshot (collection group) arrives.
  final isOrdersLoading = true.obs;

  List<Order> get orders => _orders;

  RxList<Order> get ordersRx => _orders;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _adminOrdersSub;

  @override
  void onInit() {
    super.onInit();
    _bindAdminOrdersListener();
    ever(AuthService.to.currentUser, (_) => _bindAdminOrdersListener());
    ever(AuthService.to.firebaseUser, (_) => _bindAdminOrdersListener());
  }

  @override
  void onClose() {
    _adminOrdersSub?.cancel();
    super.onClose();
  }

  /// Collection group reads **all** `users/*/orders/*`. Rules only allow that for
  /// [AuthService.isAdmin]; regular users must use [userOrdersStream] instead.
  void _bindAdminOrdersListener() {
    _adminOrdersSub?.cancel();
    _adminOrdersSub = null;

    if (!AuthService.to.isAdmin) {
      _orders.clear();
      isOrdersLoading.value = false;
      return;
    }

    isOrdersLoading.value = true;
    _adminOrdersSub = FirestoreService.ordersCollectionGroup
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
            final list = snapshot.docs
                .map(
                  (doc) => Order.fromMap(
                    doc.id,
                    doc.data(),
                    firestorePath: doc.reference.path,
                  ),
                )
                .toList();
            _orders.assignAll(list);
            isOrdersLoading.value = false;
          },
          onError: (_) {
            if (!isClosed) isOrdersLoading.value = false;
          },
        );
  }

  /// One-shot fetch for admin pull-to-refresh (mirrors stream query).
  Future<void> refreshOrdersFromServer() async {
    if (!AuthService.to.isAdmin) return;
    try {
      final snapshot = await FirestoreService.ordersCollectionGroup
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.server));
      final list = snapshot.docs
          .map(
            (doc) => Order.fromMap(
              doc.id,
              doc.data(),
              firestorePath: doc.reference.path,
            ),
          )
          .toList();
      _orders.assignAll(list);
      isOrdersLoading.value = false;
    } catch (_) {}
  }

  /// One-shot fetch for a user's orders subcollection.
  Future<List<Order>> fetchUserOrdersOnce(String uid) async {
    final snapshot = await FirestoreService.usersOrdersRef(uid)
        .orderBy('createdAt', descending: true)
        .get(const GetOptions(source: Source.server));
    return snapshot.docs
        .map((doc) => Order.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Admin: single order from `users/{buyerUid}/orders/{orderId}` (referral detail, etc.).
  Future<Order?> fetchOrderForBuyer(String buyerUid, String orderId) async {
    if (buyerUid.isEmpty || orderId.isEmpty) return null;
    try {
      final ref = FirestoreService.usersOrdersRef(buyerUid).doc(orderId);
      final snap = await ref.get(
        const GetOptions(source: Source.serverAndCache),
      );
      if (!snap.exists || snap.data() == null) return null;
      return Order.fromMap(
        snap.id,
        snap.data()!,
        firestorePath: ref.path,
      );
    } catch (_) {
      return null;
    }
  }

  /// Creates order in users/{userId}/orders subcollection.
  Future<String> createOrder(Order order) async {
    final uid = order.userId;
    if (uid == null) {
      throw StateError('Order must have userId to save.');
    }
    final col = FirestoreService.usersOrdersRef(uid);
    final doc = await col.add(order.toMap());
    return doc.id;
  }

  Future<void> updateStatus(Order order, OrderStatus status) async {
    final path = order.firestorePath;
    if (path == null) return;
    final ref = FirestoreService.instance.doc(path);
    
    final updates = <String, dynamic>{'status': status.name};
    if (status == OrderStatus.delivered) {
      updates['deliveredAt'] = FieldValue.serverTimestamp();
    }
    await ref.update(updates);
    
    if (status == OrderStatus.delivered) {
      await _grantReferrerRewardIfEligible(ref);
    }
    final uid = order.userId;
    if (uid != null && uid.isNotEmpty) {
      try {
        await OneSignalService.notifyUser(
          userId: uid,
          orderId: order.id,
          status: status.name,
        );
      } catch (_) {}
    }
  }

  /// Admin app: when order becomes [delivered], credit referrer PKR 500 once (Firestore transaction).
  Future<void> _grantReferrerRewardIfEligible(
    DocumentReference<Map<String, dynamic>> orderRef,
  ) async {
    if (!AuthService.to.isAdmin) return;
    try {
      await FirestoreService.instance.runTransaction((txn) async {
        final oSnap = await txn.get(orderRef);
        if (!oSnap.exists) return;
        final od = oSnap.data() ?? {};
        final granted = od['referralRewardGranted'] as bool? ??
            od['referralRewardActivated'] as bool? ??
            false;
        if (granted == true) return;
        final pending = od['referralRewardPending'] as bool? ?? false;
        if (pending != true) return;
        final refUid = od['referredBy'] as String? ??
            od['referralRewardReferrerUid'] as String?;
        if (refUid == null || refUid.isEmpty) return;

        final referrerRef = FirestoreService.usersCollection.doc(refUid);
        final rSnap = await txn.get(referrerRef);
        final w = rSnap.data()?['wallet'];
        double bal = 0;
        double pend = 0;
        if (w is Map) {
          bal = ((w['balance'] as num?)?.toDouble() ?? 0);
          pend = ((w['pendingRewards'] as num?)?.toDouble() ?? 0);
        }

        txn.update(orderRef, {
          'referralRewardGranted': true,
          'referralRewardPending': false,
        });

        txn.set(
          referrerRef,
          {
            'wallet': {
              'balance': bal + kReferralRewardPkr,
              'pendingRewards': pend,
            },
          },
          SetOptions(merge: true),
        );

        final recId = od['referralRecordId'] as String? ??
            od['referralRewardDocId'] as String?;
        if (recId != null && recId.isNotEmpty) {
          txn.update(
            referrerRef.collection('referrals').doc(recId),
            {
              'status': 'completed',
              'completedAt': FieldValue.serverTimestamp(),
            },
          );
        }
      });
    } catch (_) {
      // Non-fatal: admin can retry status update if rules blocked.
    }
  }

  /// Admin: mark order paid / unpaid (COD confirm at delivery, or bank verification).
  Future<void> updatePaidStatus(Order order, bool isPaid) async {
    final path = order.firestorePath;
    if (path == null) return;
    await FirestoreService.instance.doc(path).update({'isPaid': isPaid});
  }

  Future<void> cancelOrderWithReason(Order order, String reason) async {
    final path = order.firestorePath;
    if (path == null) {
      throw StateError('Order path missing');
    }
    final trimmed = reason.trim();
    if (trimmed.isEmpty) {
      throw StateError('Cancellation reason is required');
    }
    if (order.status == OrderStatus.cancelled) {
      throw StateError('Order is already cancelled');
    }
    await FirestoreService.instance.doc(path).update({
      'status': OrderStatus.cancelled.name,
      'cancellationReason': trimmed,
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancellationUnreadForUser': true,
    });
    final uid = order.userId;
    if (uid != null && uid.isNotEmpty) {
      try {
        await OneSignalService.notifyUser(
          userId: uid,
          orderId: order.id,
          status: OrderStatus.cancelled.name,
        );
      } catch (_) {}
    }
  }

  Future<void> markCancellationNoticesReadForUser(String uid) async {
    final snap = await FirestoreService.usersOrdersRef(uid)
        .where('cancellationUnreadForUser', isEqualTo: true)
        .get();
    if (snap.docs.isEmpty) return;
    final batch = FirestoreService.instance.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {'cancellationUnreadForUser': false});
    }
    await batch.commit();
  }

  /// Stream of orders for current user (users/{uid}/orders).
  Stream<List<Order>> userOrdersStream(String uid) {
    return FirestoreService.usersOrdersRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Order.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Simple aggregates for dashboard
  double get totalRevenue => orders.fold(0, (sum, o) => sum + o.total);

  int get totalOrders => orders.length;

  int get pendingCount =>
      orders.where((o) => o.status == OrderStatus.pending).length;

  int get shippedCount =>
      orders.where((o) => o.status == OrderStatus.shipped).length;

  int get deliveredCount =>
      orders.where((o) => o.status == OrderStatus.delivered).length;

  int get unpaidCount => orders.where((o) => !o.isPaid).length;

  /// Cash on delivery orders (payment at doorstep).
  int get codOrdersCount => orders.where((o) => o.isCod).length;

  /// Bank / online transfer (not COD).
  int get bankTransferOrdersCount => orders.where((o) => !o.isCod).length;

  int get paidOrdersCount => orders.where((o) => o.isPaid).length;

  /// Admin: permanently remove one order document (e.g. cleared cancelled list).
  Future<void> deleteOrderDocument(Order order) async {
    if (!AuthService.to.isAdmin) {
      throw StateError('Only admins can delete orders.');
    }
    final path = order.firestorePath;
    if (path == null) throw StateError('Order path missing');
    await FirestoreService.instance.doc(path).delete();
  }

  /// Admin: delete every cancelled order currently in memory (from collection group stream).
  Future<int> deleteAllCancelledOrders() async {
    if (!AuthService.to.isAdmin) return 0;
    final cancelled =
        orders.where((o) => o.status == OrderStatus.cancelled).toList();
    var n = 0;
    for (final o in cancelled) {
      final path = o.firestorePath;
      if (path == null) continue;
      await FirestoreService.instance.doc(path).delete();
      n++;
    }
    return n;
  }
}
