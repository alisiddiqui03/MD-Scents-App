import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../data/models/referral_entry.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// Referral system: Firestore-only (no Cloud Functions). Codes, validation, listings.
class ReferralService extends GetxService {
  ReferralService();

  static ReferralService get to => Get.find<ReferralService>();

  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _randomCode(int len) {
    final r = Random.secure();
    return List.generate(len, (_) => _chars[r.nextInt(_chars.length)]).join();
  }

  @override
  void onInit() {
    super.onInit();
    ever(AuthService.to.currentUser, (u) {
      if (u != null) {
        Future.microtask(ensureReferralCodeIfNeeded);
      }
    });
    if (AuthService.to.currentUser.value != null) {
      Future.microtask(ensureReferralCodeIfNeeded);
    }
  }

  /// Idempotent: unique [referralCodes/{code}] + [users.referralCode].
  Future<void> ensureReferralCodeIfNeeded() async {
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) return;
    final existing = AuthService.to.currentUser.value?.referralCode;
    if (existing != null && existing.trim().isNotEmpty) return;

    for (var attempt = 0; attempt < 35; attempt++) {
      final code = _randomCode(8);
      final codeRef = FirestoreService.referralCodesCollection.doc(code);
      final userRef = FirestoreService.usersCollection.doc(uid);
      try {
        await FirestoreService.instance.runTransaction((txn) async {
          final cSnap = await txn.get(codeRef);
          if (cSnap.exists) throw StateError('collision');
          final uSnap = await txn.get(userRef);
          final ex = uSnap.data()?['referralCode'] as String?;
          if (ex != null && ex.trim().isNotEmpty) throw StateError('already');
          txn.set(codeRef, {
            'uid': uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
          txn.set(userRef, {'referralCode': code}, SetOptions(merge: true));
        });
        await AuthService.to.refreshProfile();
        return;
      } catch (e) {
        if (e is StateError) {
          if (e.message == 'already') {
            await AuthService.to.refreshProfile();
            return;
          }
          if (e.message == 'collision') continue;
        }
        debugPrint('ensureReferralCodeIfNeeded: $e');
        return;
      }
    }
  }

  Future<String?> lookupReferrerUid(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return null;
    final snap = await FirestoreService.referralCodesCollection
        .doc(trimmed)
        .get(const GetOptions(source: Source.serverAndCache));
    if (!snap.exists) return null;
    return snap.data()?['uid'] as String?;
  }

  Future<ReferralCheckoutValidation> validateForFirstOrder({
    required String buyerUid,
    required String? codeEntered,
    required bool isFirstOrder,
    required String? buyerExistingReferralCode,
    required String? buyerReferredBy,
  }) async {
    if (!isFirstOrder) {
      return ReferralCheckoutValidation.none();
    }
    if (buyerReferredBy != null && buyerReferredBy.trim().isNotEmpty) {
      return ReferralCheckoutValidation.none(
        message: 'Referral already linked to your account.',
      );
    }
    final raw = codeEntered?.trim().toUpperCase();
    if (raw == null || raw.isEmpty) {
      return ReferralCheckoutValidation.none();
    }
    if (buyerExistingReferralCode != null &&
        raw == buyerExistingReferralCode.trim().toUpperCase()) {
      return ReferralCheckoutValidation.none(
        message: 'You cannot use your own referral code.',
      );
    }
    final referrerUid = await lookupReferrerUid(raw);
    if (referrerUid == null) {
      return ReferralCheckoutValidation.none(message: 'Invalid referral code.');
    }
    if (referrerUid == buyerUid) {
      return ReferralCheckoutValidation.none(
        message: 'You cannot use your own referral code.',
      );
    }
    return ReferralCheckoutValidation.ok(
      code: raw,
      referrerUid: referrerUid,
    );
  }

  Stream<List<ReferralEntry>> referralsStream(String referrerUid) {
    return FirestoreService.usersCollection
        .doc(referrerUid)
        .collection('referrals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ReferralEntry.fromDoc(d.id, d.data()))
              .toList(),
        );
  }
}

class ReferralCheckoutValidation {
  final bool isValid;
  final String? code;
  final String? referrerUid;
  final String? message;

  const ReferralCheckoutValidation._({
    required this.isValid,
    this.code,
    this.referrerUid,
    this.message,
  });

  factory ReferralCheckoutValidation.none({String? message}) =>
      ReferralCheckoutValidation._(isValid: false, message: message);

  factory ReferralCheckoutValidation.ok({
    required String code,
    required String referrerUid,
  }) =>
      ReferralCheckoutValidation._(
        isValid: true,
        code: code,
        referrerUid: referrerUid,
      );

  bool get appliesReward => isValid && referrerUid != null;
}
