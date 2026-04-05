import 'dart:async';

import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/data/models/referral_entry.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/services/referral_service.dart';

class ReferEarnController extends GetxController {
  final AuthService _auth = AuthService.to;
  final ReferralService _referral = ReferralService.to;

  final entries = <ReferralEntry>[].obs;
  final isLoadingCode = false.obs;

  StreamSubscription<List<ReferralEntry>>? _sub;

  @override
  void onInit() {
    super.onInit();
    ever(_auth.currentUser, (_) => _listenReferrals());
    _listenReferrals();
  }

  void _listenReferrals() {
    _sub?.cancel();
    final uid = _auth.currentUser.value?.uid;
    if (uid == null) {
      entries.clear();
      return;
    }
    _sub = _referral.referralsStream(uid).listen(entries.assignAll);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  String? get referralCode => _auth.currentUser.value?.referralCode;

  Future<void> refreshCode() async {
    isLoadingCode.value = true;
    try {
      await _referral.ensureReferralCodeIfNeeded();
    } finally {
      isLoadingCode.value = false;
    }
  }

  Future<void> shareCode() async {
    var code = referralCode;
    if (code == null || code.isEmpty) {
      await refreshCode();
      code = _auth.currentUser.value?.referralCode;
    }
    if (code == null || code.isEmpty) {
      Get.snackbar('Code unavailable', 'Please try again in a moment.');
      return;
    }
    await Share.share(
      'Shop MD Scents with my code $code you can enter it on your first order in the cart and get free delivery '
      'Download the MD Scents app!',
      subject: 'MD Scents referral',
    );
  }
}
