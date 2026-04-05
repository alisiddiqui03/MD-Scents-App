import 'dart:async';

import 'package:get/get.dart';

import '../../../../app/data/models/referral_entry.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/services/referral_service.dart';

/// Wallet balance + referral reward history (no share/code — see Refer & Earn).
class WalletController extends GetxController {
  final ReferralService _referral = ReferralService.to;

  final entries = <ReferralEntry>[].obs;

  StreamSubscription<List<ReferralEntry>>? _sub;

  @override
  void onInit() {
    super.onInit();
    ever(AuthService.to.currentUser, (_) => _listenReferrals());
    _listenReferrals();
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

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
