/// Placeholder for ad integration (rewarded ads, banners, etc.).
///
/// Keep API surface minimal so it can be wired to
/// Google AdMob, custom backend logic, or other providers later.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  Future<void> init() async {
    // Initialize ad SDKs here in the future.
  }

  Future<void> showRewardedDiscountAd() async {
    // Show rewarded ad and resolve when completed; caller can
    // increase discount (e.g. +1%) based on reward.
  }
}

