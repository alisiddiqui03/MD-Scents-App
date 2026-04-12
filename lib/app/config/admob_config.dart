import 'dart:io';
import 'dart:math' as math;

/// Google AdMob identifiers for MD Scents.
///
/// **App ID** (same string in AndroidManifest + iOS Info.plist `GADApplicationIdentifier`):
/// `ca-app-pub-3221693773631079~2676327540`
///
/// **Ad units:** You listed three `/` IDs. They must match the **format** you chose
/// in [AdMob Console](https://apps.admob.com/) (Rewarded / Banner / Interstitial).
/// If an ad fails to load, open Console → Ad units and confirm which ID is which,
/// then swap assignments below.
class AdmobConfig {
  AdmobConfig._();

  // ── App IDs (with ~) — used only in native manifests, not in Dart ad load calls ──
  static const String androidAppId = 'ca-app-pub-3221693773631079~2676327540';
  static const String iosAppId = 'ca-app-pub-3221693773631079~2676327540';

  // ── Production ad unit IDs (with /) ─────────────────────────────────────────
  /// **Rewarded** — "Watch ad to boost discount" on Offers & Discounts.
  static const String androidRewardedUnitId =
      'ca-app-pub-3221693773631079/6137635769';
  static const String iosRewardedUnitId =
      'ca-app-pub-3221693773631079/6137635769';

  /// **Banner** — bottom of discount / offers screen.
  static const String androidBannerUnitId =
      'ca-app-pub-3221693773631079/2808189480';
  static const String iosBannerUnitId =
      'ca-app-pub-3221693773631079/2808189480';

  /// **Interstitial** — optional full-screen (preload; show only at safe UX points).
  static const String androidInterstitialUnitId =
      'ca-app-pub-3221693773631079/4544510232';
  static const String iosInterstitialUnitId =
      'ca-app-pub-3221693773631079/4544510232';

  // ── Google official test IDs (safe for development; no policy risk) ────────
  static const String androidTestRewarded =
      'ca-app-pub-3940256099942544/5224354917';
  static const String iosTestRewarded =
      'ca-app-pub-3940256099942544/1712485313';
  static const String androidTestBanner =
      'ca-app-pub-3940256099942544/6300978111';
  static const String iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String iosTestInterstitial =
      'ca-app-pub-3940256099942544/4411468910';

  /// When `true`, debug builds use [Google test ad units](https://developers.google.com/admob/android/test-ads).
  /// Set to `false` to load **your** real units while debugging (use sparingly).
  static const bool forceTestAdsInDebug = true;

  // ── Load retry / UX policy (not ad unit IDs) ────────────────────────────────

  /// Stop exponential backoff after this many consecutive load failures per format.
  static const int maxConsecutiveLoadFailures = 12;

  /// Minimum time between interstitial presentations (persisted; policy-friendly).
  static const Duration interstitialMinInterval = Duration(minutes: 5);

  /// Backoff in seconds after failed loads: capped exponential.
  static int retryDelaySeconds(int failStreak) {
    final raw = 1 << math.min(failStreak, 6);
    return math.min(120, math.max(2, raw));
  }

  static String rewardedUnitId({required bool useTest}) {
    if (useTest) {
      return Platform.isAndroid ? androidTestRewarded : iosTestRewarded;
    }
    return Platform.isAndroid ? androidRewardedUnitId : iosRewardedUnitId;
  }

  static String bannerUnitId({required bool useTest}) {
    if (useTest) {
      return Platform.isAndroid ? androidTestBanner : iosTestBanner;
    }
    return Platform.isAndroid ? androidBannerUnitId : iosBannerUnitId;
  }

  static String interstitialUnitId({required bool useTest}) {
    if (useTest) {
      return Platform.isAndroid ? androidTestInterstitial : iosTestInterstitial;
    }
    return Platform.isAndroid
        ? androidInterstitialUnitId
        : iosInterstitialUnitId;
  }
}
