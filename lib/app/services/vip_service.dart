import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:get/get.dart';

import '../data/models/order.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import 'points_service.dart';

class VipService extends GetxService {
  VipService();

  static VipService get to => Get.find<VipService>();

  static const double highRollerThresholdPkr = 1000000;
  static const int highRollerBonusPoints = 10000;
  static const double monthlyPlanPkr = 1500;
  static const double yearlyPlanPkr = 15000;
  static const double yearlySavingsPkr = 3000;

  bool isVipActiveFromUserData(Map<String, dynamic> userData, DateTime now) {
    final isVip = userData['isVip'] as bool? ?? false;
    if (!isVip) return false;
    final endTs = userData['vipEndDate'];
    final end = endTs is Timestamp ? endTs.toDate() : null;
    if (end == null) return false;
    return end.isAfter(now);
  }

  bool isYearlyVipFromUserData(Map<String, dynamic> userData) {
    final t = (userData['vipType'] as String?)?.trim().toLowerCase();
    return t == 'yearly';
  }

  /// Called after order placement; updates High Roller spend + grants bonus once.
  /// Must run inside the same transaction as the order placement.
  int handleVipBenefits({
    required Transaction txn,
    required DocumentReference<Map<String, dynamic>> userRef,
    required String uid,
    required Map<String, dynamic> userData,
    required Order order,
    required int currentPoints,
    DateTime? now,
  }) {
    final tNow = now ?? DateTime.now();
    if (!isVipActiveFromUserData(userData, tNow)) return currentPoints;

    // Currently: "Free delivery" is a pricing rule; this app doesn't charge a delivery fee.
    // No order-cost mutation needed here.

    if (!isYearlyVipFromUserData(userData)) return currentPoints;

    var spent = (userData['vipHighRollerSpent'] as num?)?.toDouble() ?? 0.0;
    if (spent < 0) spent = 0;
    final alreadyGiven = userData['vipHighRollerRewardGiven'] as bool? ?? false;

    final nextSpent = spent + order.total;
    txn.set(
      userRef,
      {'vipHighRollerSpent': nextSpent},
      SetOptions(merge: true),
    );

    if (alreadyGiven) return currentPoints;
    if (nextSpent + 1e-6 < highRollerThresholdPkr) return currentPoints;

    txn.set(
      userRef,
      {'vipHighRollerRewardGiven': true},
      SetOptions(merge: true),
    );

    return PointsService.to.addPointsInTransaction(
      txn: txn,
      userRef: userRef,
      uid: uid,
      currentPoints: currentPoints,
      deltaPoints: highRollerBonusPoints,
      type: 'vip_high_roller',
      referenceId: order.id,
      now: tNow,
    );
  }

  /// Admin-only: activates VIP for a user. Must be called from admin UI.
  Future<void> activateVipForUser({
    required String uid,
    required String vipType, // "monthly" | "yearly"
  }) async {
    final trimmed = vipType.trim().toLowerCase();
    if (trimmed != 'monthly' && trimmed != 'yearly') {
      throw StateError('Invalid VIP type');
    }

    final userRef = FirestoreService.usersCollection.doc(uid);
    await FirestoreService.instance.runTransaction((txn) async {
      final snap = await txn.get(userRef);
      if (!snap.exists) {
        throw StateError('User not found');
      }
      final now = DateTime.now();
      final end = trimmed == 'monthly'
          ? now.add(const Duration(days: 30))
          : now.add(const Duration(days: 365));
      txn.set(
        userRef,
        {
          'isVip': true,
          'vipType': trimmed,
          'vipStartDate': FieldValue.serverTimestamp(),
          'vipEndDate': Timestamp.fromDate(end),
          'vipHighRollerSpent': 0.0,
          'vipHighRollerRewardGiven': false,
        },
        SetOptions(merge: true),
      );
    });
  }

  /// Admin: end VIP benefits (user must contact support to cancel billing).
  Future<void> deactivateVipForUser({required String uid}) async {
    await FirestoreService.usersCollection.doc(uid).set(
      {
        'isVip': false,
        'vipEndDate': Timestamp.fromDate(DateTime.now()),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> submitVipPaymentRequest({
    required String planType,
    required String screenshotUrl,
  }) async {
    final uid = AuthService.to.currentUser.value?.uid;
    final user = AuthService.to.currentUser.value;
    if (uid == null || user == null) {
      throw StateError('User is not signed in');
    }
    final p = planType.trim().toLowerCase();
    if (p != 'monthly' && p != 'yearly') {
      throw StateError('Invalid VIP plan');
    }
    if (screenshotUrl.trim().isEmpty) {
      throw StateError('Payment screenshot is required');
    }

    final reqRef = FirestoreService.vipRequestsCollection.doc(uid);
    await reqRef.set({
      'uid': uid,
      'userName': (user.displayName ?? '').trim(),
      'userEmail': (user.email ?? '').trim(),
      'planType': p,
      'planPrice': p == 'monthly' ? monthlyPlanPkr : yearlyPlanPkr,
      'yearlySavingsPkr': yearlySavingsPkr,
      'screenshotUrl': screenshotUrl.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

