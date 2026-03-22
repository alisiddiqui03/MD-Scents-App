import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../data/models/order.dart';
import '../services/firestore_service.dart';

/// Order data + admin-facing helpers backed by Firestore.
class OrderService extends GetxService {
  OrderService();

  static OrderService get to => Get.find<OrderService>();

  final _orders = <Order>[].obs;

  /// True until first orders snapshot (collection group) arrives.
  final isOrdersLoading = true.obs;

  List<Order> get orders => _orders;

  @override
  void onInit() {
    super.onInit();
    _listenToOrders();
  }

  void _listenToOrders() {
    FirestoreService.ordersCollectionGroup
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final list = snapshot.docs
          .map((doc) => Order.fromMap(
                doc.id,
                doc.data(),
                firestorePath: doc.reference.path,
              ))
          .toList();
      _orders.assignAll(list);
      isOrdersLoading.value = false;
    });
  }

  /// One-shot fetch for admin pull-to-refresh (mirrors stream query).
  Future<void> refreshOrdersFromServer() async {
    try {
      final snapshot = await FirestoreService.ordersCollectionGroup
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.server));
      final list = snapshot.docs
          .map((doc) => Order.fromMap(
                doc.id,
                doc.data(),
                firestorePath: doc.reference.path,
              ))
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
    await FirestoreService.instance.doc(path).update({'status': status.name});
  }

  /// Admin: mark order paid / unpaid (COD confirm at delivery, or bank verification).
  Future<void> updatePaidStatus(Order order, bool isPaid) async {
    final path = order.firestorePath;
    if (path == null) return;
    await FirestoreService.instance.doc(path).update({'isPaid': isPaid});
  }

  /// Stream of orders for current user (users/{uid}/orders).
  Stream<List<Order>> userOrdersStream(String uid) {
    return FirestoreService.usersOrdersRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Simple aggregates for dashboard
  double get totalRevenue =>
      orders.fold(0, (sum, o) => sum + o.total);

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
}

