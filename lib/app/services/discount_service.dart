import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'auth_service.dart';
import 'firestore_service.dart';

/// User-level discount progression service.
///
/// Rules:
/// - First login/register: one-time 5% welcome discount.
/// - Welcome discount blocks ad-based increment until it is used.
/// - After usage: discount resets to 0 and ad progression is enabled.
/// - Ad progression:
///   0-5%  => +1% per 1 ad
///   5-10% => +1% per 2 ads
///   10-15% => +1% per 4 ads
///   15-20% => +1% per 8 ads
class DiscountService extends GetxService {
  DiscountService();

  static DiscountService get to => Get.find<DiscountService>();

  final currentDiscountPercent = 0.0.obs;
  final adsWatchedCount = 0.obs;
  final hasReceivedWelcomeDiscount = false.obs;
  final hasUsedWelcomeDiscount = false.obs;

  final isLoading = true.obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    ever(AuthService.to.currentUser, (_) => _bindCurrentUser());
    _bindCurrentUser();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  int get maxDiscountPercent => 20;

  bool get isWelcomeDiscountActive =>
      hasReceivedWelcomeDiscount.value &&
      !hasUsedWelcomeDiscount.value &&
      currentDiscountPercent.value >= 5;

  bool get isAdProgressionEnabled => hasUsedWelcomeDiscount.value;

  int get adsNeededForNextPercent {
    final d = currentDiscountPercent.value;
    if (d >= maxDiscountPercent) return 0;
    if (d < 5) return 1;
    if (d < 10) return 2;
    if (d < 15) return 4;
    return 8;
  }

  Future<void> _bindCurrentUser() async {
    _sub?.cancel();
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) {
      _setLocalState(
        discount: 0,
        adsCount: 0,
        received: false,
        used: false,
      );
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    final ref = FirestoreService.usersCollection.doc(uid);
    _sub = ref.snapshots().listen((doc) async {
      final data = doc.data() ?? <String, dynamic>{};
      var received = data['hasReceivedWelcomeDiscount'] as bool? ?? false;
      var used = data['hasUsedWelcomeDiscount'] as bool? ?? false;
      var discount = (data['currentDiscountPercent'] as num?)?.toDouble() ?? 0;
      var adsCount = (data['adsWatchedCount'] as num?)?.toInt() ?? 0;

      // First-time welcome grant.
      if (!received) {
        received = true;
        used = false;
        discount = 5;
        adsCount = 0;
        await ref.set({
          'hasReceivedWelcomeDiscount': true,
          'hasUsedWelcomeDiscount': false,
          'currentDiscountPercent': 5.0,
          'adsWatchedCount': 0,
          'discountUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      _setLocalState(
        discount: discount,
        adsCount: adsCount,
        received: received,
        used: used,
      );
      isLoading.value = false;
    });
  }

  void _setLocalState({
    required double discount,
    required int adsCount,
    required bool received,
    required bool used,
  }) {
    currentDiscountPercent.value = discount.clamp(0, maxDiscountPercent).toDouble();
    adsWatchedCount.value = adsCount < 0 ? 0 : adsCount;
    hasReceivedWelcomeDiscount.value = received;
    hasUsedWelcomeDiscount.value = used;
  }

  Future<void> onRewardedAdEarned() async {
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) return;

    // Welcome discount is active; ads do not increase.
    if (isWelcomeDiscountActive) return;

    if (currentDiscountPercent.value >= maxDiscountPercent) return;

    final ref = FirestoreService.usersCollection.doc(uid);
    await FirestoreService.instance.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final data = snap.data() ?? <String, dynamic>{};

      var received = data['hasReceivedWelcomeDiscount'] as bool? ?? false;
      var used = data['hasUsedWelcomeDiscount'] as bool? ?? false;
      var discount = (data['currentDiscountPercent'] as num?)?.toDouble() ?? 0;
      var watched = (data['adsWatchedCount'] as num?)?.toInt() ?? 0;

      if (!received) {
        // Defensive: still grant welcome if somehow absent.
        received = true;
        used = false;
        discount = 5;
        watched = 0;
      }

      if (!used && discount >= 5) {
        // Welcome phase blocks ad progression.
        txn.set(ref, {
          'hasReceivedWelcomeDiscount': true,
          'hasUsedWelcomeDiscount': false,
          'currentDiscountPercent': 5.0,
          'adsWatchedCount': 0,
          'discountUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }

      if (discount >= maxDiscountPercent) return;

      watched += 1;
      final need = _adsNeededFor(discount);
      if (watched >= need) {
        watched = 0;
        discount = (discount + 1).clamp(0, maxDiscountPercent).toDouble();
      }

      txn.set(ref, {
        'hasReceivedWelcomeDiscount': true,
        'hasUsedWelcomeDiscount': true,
        'currentDiscountPercent': discount,
        'adsWatchedCount': watched,
        'discountUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> consumeDiscountOnPurchaseIfAny() async {
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) return;
    if (currentDiscountPercent.value <= 0) return;

    final ref = FirestoreService.usersCollection.doc(uid);
    await ref.set({
      'currentDiscountPercent': 0.0,
      'adsWatchedCount': 0,
      'hasReceivedWelcomeDiscount': true,
      'hasUsedWelcomeDiscount': true,
      'discountUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  int _adsNeededFor(double discount) {
    if (discount >= maxDiscountPercent) return 0;
    if (discount < 5) return 1;
    if (discount < 10) return 2;
    if (discount < 15) return 4;
    return 8;
  }
}

