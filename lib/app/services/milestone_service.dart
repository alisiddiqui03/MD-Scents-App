import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:get/get.dart';

import '../data/models/order.dart';
import 'points_service.dart';

class MilestoneService extends GetxService {
  MilestoneService();

  static MilestoneService get to => Get.find<MilestoneService>();

  static const Duration cycleDuration = Duration(days: 90);
  static const Duration perOrderCooldown = Duration(hours: 24);
  static const double qualifyingMinPkr = 10000;

  /// Rewards based on qualifying order count within the current 90-day cycle.
  static const Map<int, int> milestoneRewards = {
    1: 50,
    5: 100,
    10: 1000,
  };

  /// Handles 90-day global milestone logic and grants reward points when applicable.
  ///
  /// Must be called **inside** a Firestore transaction.
  int handleMilestone({
    required Transaction txn,
    required DocumentReference<Map<String, dynamic>> userRef,
    required String uid,
    required Map<String, dynamic> userData,
    required Order order,
    required int currentPoints,
    DateTime? now,
  }) {
    final tNow = now ?? DateTime.now();

    // Must meet min order total.
    if (order.total + 1e-6 < qualifyingMinPkr) {
      _resetIfExpired(txn: txn, userRef: userRef, userData: userData, now: tNow);
      return currentPoints;
    }

    // Read fields.
    final startTs = userData['milestoneStartDate'];
    DateTime? start =
        startTs is Timestamp ? startTs.toDate() : null;

    final lastTs = userData['lastMilestoneOrderTime'];
    DateTime? last =
        lastTs is Timestamp ? lastTs.toDate() : null;

    var count = (userData['milestoneOrderCount'] as num?)?.toInt() ?? 0;
    if (count < 0) count = 0;

    // Reset cycle if expired.
    if (start == null || tNow.isAfter(start.add(cycleDuration))) {
      start = tNow;
      last = null;
      count = 0;
      txn.set(
        userRef,
        {
          'milestoneStartDate': Timestamp.fromDate(start),
          'milestoneOrderCount': 0,
          'lastMilestoneOrderTime': null,
        },
        SetOptions(merge: true),
      );
    }

    // 24h cooldown.
    if (last != null && tNow.difference(last) < perOrderCooldown) {
      return currentPoints;
    }

    // Increment.
    final nextCount = count + 1;
    txn.set(
      userRef,
      {
        'milestoneOrderCount': nextCount,
        'lastMilestoneOrderTime': Timestamp.fromDate(tNow),
      },
      SetOptions(merge: true),
    );

    // Reward if this count hits a milestone.
    final reward = milestoneRewards[nextCount] ?? 0;
    if (reward <= 0) return currentPoints;

    return PointsService.to.addPointsInTransaction(
      txn: txn,
      userRef: userRef,
      uid: uid,
      currentPoints: currentPoints,
      deltaPoints: reward,
      type: 'milestone',
      referenceId: 'milestone_$nextCount:${order.id}',
      now: tNow,
    );
  }

  void _resetIfExpired({
    required Transaction txn,
    required DocumentReference<Map<String, dynamic>> userRef,
    required Map<String, dynamic> userData,
    required DateTime now,
  }) {
    final startTs = userData['milestoneStartDate'];
    final start = startTs is Timestamp ? startTs.toDate() : null;
    if (start == null) return;
    if (!now.isAfter(start.add(cycleDuration))) return;
    txn.set(
      userRef,
      {
        'milestoneStartDate': Timestamp.fromDate(now),
        'milestoneOrderCount': 0,
        'lastMilestoneOrderTime': null,
      },
      SetOptions(merge: true),
    );
  }
}

