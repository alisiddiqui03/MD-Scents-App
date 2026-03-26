/// Outcome of attempting to present a rewarded ad (discount boost flow).
class RewardedPresentationResult {
  const RewardedPresentationResult({
    required this.presentationStarted,
    required this.rewardEarned,
    this.failureReason,
  });

  /// `true` if [RewardedAd.show] was invoked with a loaded ad.
  final bool presentationStarted;

  /// `true` only when the SDK fires [onUserEarnedReward] (user completed the ad).
  final bool rewardEarned;

  final RewardedFailureReason? failureReason;

  bool get shouldPromptRetry =>
      !presentationStarted && failureReason != RewardedFailureReason.busy;

  /// When the ad was shown but the user closed early (no [onUserEarnedReward]).
  String get incompleteRewardHint =>
      presentationStarted && !rewardEarned
          ? 'Watch the full ad to earn your discount boost.'
          : '';

  /// User-facing fallback when [presentationStarted] is false.
  String get fallbackMessage {
    switch (failureReason) {
      case RewardedFailureReason.noNetwork:
        return 'No internet connection. Connect and try again.';
      case RewardedFailureReason.noInventory:
      case RewardedFailureReason.sdkNotInitialized:
        return 'Ad not available right now. Please try again in a moment.';
      case RewardedFailureReason.busy:
        return 'Please wait for the current ad to finish.';
      case RewardedFailureReason.failedToShow:
        return 'Could not show the ad. Please try again.';
      case null:
        return 'Something went wrong. Please try again.';
    }
  }
}

enum RewardedFailureReason {
  sdkNotInitialized,
  noNetwork,
  noInventory,
  busy,
  failedToShow,
}

/// Interstitial was skipped or not shown (non-error cases are normal).
class InterstitialPresentationResult {
  const InterstitialPresentationResult({
    required this.shown,
    this.skippedReason,
  });

  final bool shown;
  final String? skippedReason;
}
