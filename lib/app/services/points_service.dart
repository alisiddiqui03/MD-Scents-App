import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:get/get.dart';

import '../data/models/order.dart';
import '../data/models/points_history.dart';
import 'firestore_service.dart';

class PointsService extends GetxService {
  PointsService();

  static PointsService get to => Get.find<PointsService>();

  /// Normal: 1 point per 200 PKR. VIP: 2 points per 200 PKR.
  int calculateEarnedPoints({required double orderPaidTotal, required bool isVip}) {
    final base = (orderPaidTotal / 200).floor();
    if (base <= 0) return 0;
    return isVip ? base * 2 : base;
  }

  /// Transaction-safe helper: updates `users/{uid}.points` and logs under `points_history`.
  /// Returns the new points total.
  int addPointsInTransaction({
    required Transaction txn,
    required DocumentReference<Map<String, dynamic>> userRef,
    required String uid,
    required int currentPoints,
    required int deltaPoints,
    required String type,
    String? referenceId,
    DateTime? now,
  }) {
    if (deltaPoints == 0) return currentPoints;
    final next = currentPoints + deltaPoints;
    txn.update(userRef, {'points': next});

    final historyRef = FirestoreService.usersPointsHistoryRef(uid).doc();
    final item = PointHistoryItem(
      id: historyRef.id,
      type: type,
      points: deltaPoints,
      createdAt: now ?? DateTime.now(),
      referenceId: referenceId,
    );
    txn.set(historyRef, item.toMap());
    return next;
  }

  /// Earn points for a successful order placement (inside same transaction).
  int handleOrderPoints({
    required Transaction txn,
    required DocumentReference<Map<String, dynamic>> userRef,
    required String uid,
    required Map<String, dynamic> userData,
    required Order order,
    required bool isVip,
    DateTime? now,
  }) {
    final currentPoints = (userData['points'] as num?)?.toInt() ?? 0;
    final earned =
        calculateEarnedPoints(orderPaidTotal: order.total, isVip: isVip);
    return addPointsInTransaction(
      txn: txn,
      userRef: userRef,
      uid: uid,
      currentPoints: currentPoints,
      deltaPoints: earned,
      type: 'order',
      referenceId: order.id,
      now: now,
    );
  }
}

