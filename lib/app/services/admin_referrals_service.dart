import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'auth_service.dart';
import 'firestore_service.dart';

/// Admin-only overview: collection group `users/{uid}/referrals`.
class AdminReferralRow {
  final String referrerUid;
  final String referralDocId;
  final String referredUserId;
  final String orderId;
  final String status;
  final double rewardAmount;
  final String? referredUserName;
  final String? referredUserEmail;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const AdminReferralRow({
    required this.referrerUid,
    required this.referralDocId,
    required this.referredUserId,
    required this.orderId,
    required this.status,
    required this.rewardAmount,
    this.referredUserName,
    this.referredUserEmail,
    this.createdAt,
    this.completedAt,
  });
}

class AdminReferralsService extends GetxService {
  AdminReferralsService();

  static AdminReferralsService get to => Get.find<AdminReferralsService>();

  final rows = <AdminReferralRow>[].obs;
  final isLoading = true.obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    ever(AuthService.to.currentUser, (_) => _attach());
    _attach();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _attach() {
    _sub?.cancel();
    if (!AuthService.to.isAdmin) {
      rows.clear();
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    // Server orderBy('createdAt') needs COLLECTION_GROUP index; sort client-side
    // until indexes are deployed (firebase deploy --only firestore:indexes).
    _sub = FirestoreService.instance
        .collectionGroup('referrals')
        .snapshots()
        .listen(
      (snap) {
        final list = snap.docs.map((d) {
          final parts = d.reference.path.split('/');
          // users/{uid}/referrals/{id}
          final referrerUid = parts.length >= 2 ? parts[1] : '';
          final data = d.data();
          final cr = data['createdAt'];
          DateTime? created;
          if (cr is Timestamp) created = cr.toDate();
          final cp = data['completedAt'];
          DateTime? completed;
          if (cp is Timestamp) completed = cp.toDate();
          return AdminReferralRow(
            referrerUid: referrerUid,
            referralDocId: d.id,
            referredUserId: data['referredUserId'] as String? ?? '',
            orderId: data['orderId'] as String? ?? '',
            status: data['status'] as String? ?? 'pending',
            rewardAmount: (data['rewardAmount'] as num?)?.toDouble() ?? 0,
            referredUserName: data['referredUserName'] as String?,
            referredUserEmail: data['referredUserEmail'] as String?,
            createdAt: created,
            completedAt: completed,
          );
        }).toList();

        list.sort((a, b) {
          final ta = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final tb = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return tb.compareTo(ta);
        });
        const maxRows = 300;
        if (list.length > maxRows) {
          rows.assignAll(list.sublist(0, maxRows));
        } else {
          rows.assignAll(list);
        }
        isLoading.value = false;
      },
      onError: (e, st) {
        debugPrint(
          'AdminReferralsService: collectionGroup(referrals) failed. '
          'Deploy firestore.indexes.json (firebase deploy --only firestore:indexes). '
          'Error: $e',
        );
        debugPrint('$st');
        isLoading.value = false;
      },
    );
  }
}
