import 'dart:async';

import 'package:get/get.dart';

import '../../../../app/data/models/referral_entry.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/services/referral_service.dart';
import '../../../../app/services/firestore_service.dart';
import 'package:md_scents_app/app/data/models/points_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Wallet balance + referral reward history (no share/code — see Refer & Earn).
class WalletController extends GetxController {
  final ReferralService _referral = ReferralService.to;

  final entries = <ReferralEntry>[].obs;
  final pointsHistory = <PointHistoryItem>[].obs;
  final isRedeeming = false.obs;

  StreamSubscription<List<ReferralEntry>>? _sub;
  StreamSubscription? _pointsSub;

  @override
  void onInit() {
    super.onInit();
    ever(AuthService.to.currentUser, (_) {
      _listenReferrals();
      _listenPointsHistory();
    });
    _listenReferrals();
    _listenPointsHistory();
  }

  void _listenReferrals() {
    _sub?.cancel();
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) {
      entries.clear();
      return;
    }
    _sub = _referral.referralsStream(uid).listen(entries.assignAll);
  }

  void _listenPointsHistory() {
    _pointsSub?.cancel();
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) {
      pointsHistory.clear();
      return;
    }
    _pointsSub = FirestoreService.usersPointsHistoryRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
      pointsHistory.value = snap.docs
          .map((d) => PointHistoryItem.fromMap(d.id, d.data()))
          .toList();
    });
  }

  Future<void> redeemPoints() async {
    final user = AuthService.to.currentUser.value;
    if (user == null) return;

    if (user.points < 500) {
      Get.snackbar('Insufficient Points', 'You need at least 500 points to redeem.');
      return;
    }

    isRedeeming.value = true;
    try {
      final userRef = FirestoreService.usersCollection.doc(user.uid);
      final historyRef = FirestoreService.usersPointsHistoryRef(user.uid).doc();

      await FirestoreService.instance.runTransaction((txn) async {
        final snap = await txn.get(userRef);
        final data = snap.data() ?? {};
        final currentPoints = (data['points'] as num?)?.toInt() ?? 0;

        if (currentPoints < 500) {
          throw 'Insufficient points in real-time. Please refresh.';
        }

        final w = data['wallet'];
        double bal = 0;
        double pend = 0;
        if (w is Map) {
          bal = (w['balance'] as num?)?.toDouble() ?? 0;
          pend = (w['pendingRewards'] as num?)?.toDouble() ?? 0;
        }

        // 1. Deduct points
        txn.update(userRef, {
          'points': currentPoints - 500,
          'wallet': {
            'balance': bal + 2500.0,
            'pendingRewards': pend,
          },
        });

        // 2. Log history
        final redeemEntry = PointHistoryItem(
          id: historyRef.id,
          type: 'redeem',
          points: -500,
          createdAt: DateTime.now(),
        );
        txn.set(historyRef, redeemEntry.toMap());
      });

      Get.snackbar(
        'Redemption Successful! 🎉',
        '500 points redeemed for 2500 PKR wallet balance.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Redemption Failed', e.toString());
    } finally {
      isRedeeming.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    _pointsSub?.cancel();
    super.onClose();
  }
}
