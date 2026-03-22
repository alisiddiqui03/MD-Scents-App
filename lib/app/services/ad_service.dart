import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Clean helper for AdMob rewarded ads.
/// Uses test ad IDs by default; replace real IDs when ready.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  bool get isAdReady => _rewardedAd != null;
  bool get isLoading => _isLoading;

  /// Replace this with your real unit ID later.
  static const String _rewardedAdUnitId = 'YOUR_REWARDED_AD_ID';

  /// Keep true during development to avoid invalid traffic.
  static const bool _useTestAds = true;

  String get _unitId {
    if (_useTestAds) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      }
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return _rewardedAdUnitId;
  }

  Future<void> init() async {
    await MobileAds.instance.initialize();
    print('[AdService] MobileAds initialized');
    loadRewardedAd();
  }

  void loadRewardedAd() {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;
    print('[AdService] Loading rewarded ad...');

    RewardedAd.load(
      adUnitId: _unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isLoading = false;
          print('[AdService] Rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isLoading = false;
          print('[AdService] Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  Future<bool> showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
  }) async {
    final ad = _rewardedAd;
    if (ad == null) {
      print('[AdService] No rewarded ad ready. Reloading...');
      loadRewardedAd();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('[AdService] Rewarded ad showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('[AdService] Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('[AdService] Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdImpression: (ad) => print('[AdService] Rewarded ad impression'),
      onAdClicked: (ad) => print('[AdService] Rewarded ad clicked'),
    );

    await ad.show(onUserEarnedReward: (ad, reward) {
      print(
        '[AdService] User earned reward: ${reward.amount} ${reward.type}',
      );
      onUserEarnedReward(reward);
    });

    return true;
  }
}

