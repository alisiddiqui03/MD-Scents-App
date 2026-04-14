import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'auth_service.dart';
import 'firestore_service.dart';

/// Reads wallet fields from `users/{uid}` (updated by checkout, admin referral grant, etc.).
class WalletService extends GetxService {
  WalletService();

  static WalletService get to => Get.find<WalletService>();

  final balance = 0.0.obs;
  final pendingRewards = 0.0.obs;
  final points = 0.obs;
  final isLoading = true.obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    ever(AuthService.to.currentUser, (_) => _bind());
    _bind();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  void _bind() {
    _sub?.cancel();
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) {
      balance.value = 0;
      pendingRewards.value = 0;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    _sub = FirestoreService.usersCollection.doc(uid).snapshots().listen((doc) {
      final data = doc.data() ?? {};
      final w = data['wallet'];
      if (w is Map) {
        balance.value = ((w['balance'] as num?)?.toDouble() ?? 0).clamp(0, 1e12);
        pendingRewards.value =
            ((w['pendingRewards'] as num?)?.toDouble() ?? 0).clamp(0, 1e12);
      } else {
        balance.value = 0;
        pendingRewards.value = 0;
      }
      points.value = (data['points'] as num?)?.toInt() ?? 0;
      isLoading.value = false;
    });
  }
}
