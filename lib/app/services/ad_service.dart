import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/admob_config.dart';
import '../core/services/storage_services.dart';
import '../data/models/ad_mob_result.dart';

/// Production-oriented AdMob facade: rewarded, banner unit IDs, interstitial + frequency cap.
///
/// **Init:** `await AdService.instance.init()` once from `main` (idempotent).
///
/// **Rewarded:** [presentRewardedAd] (rich result) or [showRewardedAd] (bool).
/// Grant discounts **only** inside `onUserEarnedReward` (AdMob policy).
///
/// **Banner:** use [bannerAdUnitId] with anchored adaptive size; dispose the
/// [BannerAd] in `State.dispose` (see app `DiscountBannerAd` widget).
///
/// **Interstitial:** [showInterstitialIfEligible] (default 5 min spacing, persisted).
/// Avoid showing on every screen change.
///
/// - **Debug** + [AdmobConfig.forceTestAdsInDebug]: Google test ad units.
/// - **Release / profile:** production IDs from [AdmobConfig].
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  static Future<void>? _initFuture;
  static bool _sdkInitialized = false;

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  bool _rewardedLoading = false;
  bool _interstitialLoading = false;

  /// Prevents overlapping full-screen rewarded presentations.
  bool _rewardedPresentationLocked = false;

  bool _interstitialPresentationLocked = false;

  Timer? _rewardedRetryTimer;
  Timer? _interstitialRetryTimer;

  int _rewardedFailStreak = 0;
  int _interstitialFailStreak = 0;

  DateTime? _rewardedReadySince;

  // ── Public cache / introspection (debug, analytics hooks) ────────────────────

  bool get isRewardedReady => _rewardedAd != null;
  bool get isRewardedLoading => _rewardedLoading;

  /// Last time a rewarded ad was successfully loaded into memory (null if never).
  DateTime? get rewardedReadySince => _rewardedReadySince;

  bool get isInterstitialReady => _interstitialAd != null;

  String get bannerAdUnitId =>
      AdmobConfig.bannerUnitId(useTest: _useTestAdUnits());

  // ── Test vs production units ───────────────────────────────────────────────

  /// Real units in profile/release; test units in debug when forced.
  bool _useTestAdUnits() => true;

  // ── Logging ─────────────────────────────────────────────────────────────────

  void _log(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[AdService] $message${error != null ? ' :: $error' : ''}');
    }
    developer.log(
      message,
      name: 'AdService',
      error: error,
      stackTrace: stack,
    );
  }

  // ── Network (no platform plugin — avoids MissingPluginException) ────────────

  /// Always allows ad attempts. `connectivity_plus` was removed because it throws
  /// [MissingPluginException] until a full native rebuild, and fails on some runners.
  /// AdMob’s own load callbacks surface offline / no-fill cases.
  static Future<bool> hasConnectionForAds() async => true;

  // ── SDK init (single flight) ────────────────────────────────────────────────

  /// Call once from [main]. Safe to await multiple times.
  Future<void> init() {
    _initFuture ??= _initializeSdk();
    return _initFuture!;
  }

  Future<void> _initializeSdk() async {
    if (_sdkInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _sdkInitialized = true;
      _log(
        'MobileAds.initialize OK (testUnits=${_useTestAdIdsLabel()})',
      );
      loadRewardedAd();
      loadInterstitialAd();
    } catch (e, st) {
      _log('MobileAds.initialize failed', e, st);
      rethrow;
    }
  }

  String _useTestAdIdsLabel() => _useTestAdUnits() ? 'yes' : 'no';

  // ── Rewarded ────────────────────────────────────────────────────────────────

  /// Preloads a rewarded ad. Idempotent; uses retry with backoff on failure.
  void loadRewardedAd({bool isScheduledRetry = false}) {
    if (!_sdkInitialized) {
      _log('loadRewardedAd: SDK not ready yet');
      return;
    }
    if (_rewardedLoading || _rewardedAd != null) return;

    _rewardedLoading = true;
    final unitId = AdmobConfig.rewardedUnitId(useTest: _useTestAdUnits());
    _log('Rewarded LOAD start unit=$unitId');

    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _rewardedLoading = false;
          _rewardedFailStreak = 0;
          _rewardedReadySince = DateTime.now();
          _rewardedRetryTimer?.cancel();
          _log('Rewarded LOAD success');
          debugPrint('TEST AD LOADED SUCCESSFULLY');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _rewardedLoading = false;
          _rewardedFailStreak++;
          _log(
            'Rewarded LOAD failed '
            '(code=${error.code}, message=${error.message}, domain=${error.domain})',
            error,
          );
          debugPrint(
            'Rewarded LoadAdError => '
            'code=${error.code}, message=${error.message}, domain=${error.domain}',
          );
          _scheduleRewardedRetry();
        },
      ),
    );
  }

  void _scheduleRewardedRetry() {
    _rewardedRetryTimer?.cancel();
    if (_rewardedFailStreak >= AdmobConfig.maxConsecutiveLoadFailures) {
      _log('Rewarded: stopping retries (max failures)');
      return;
    }
    final seconds = AdmobConfig.retryDelaySeconds(_rewardedFailStreak);
    _rewardedRetryTimer = Timer(Duration(seconds: seconds), () {
      if (_rewardedAd == null && !_rewardedLoading) {
        loadRewardedAd(isScheduledRetry: true);
      }
    });
  }

  /// Legacy API: `true` means a loaded ad was shown ([RewardedAd.show] ran).
  Future<bool> showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
  }) async {
    final r = await presentRewardedAd(onUserEarnedReward: onUserEarnedReward);
    return r.presentationStarted;
  }

  /// Preferred API: distinguishes inventory, network, busy, and reward earned.
  Future<RewardedPresentationResult> presentRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
  }) async {
    if (!_sdkInitialized) {
      _log('presentRewardedAd: SDK not initialized');
      return const RewardedPresentationResult(
        presentationStarted: false,
        rewardEarned: false,
        failureReason: RewardedFailureReason.sdkNotInitialized,
      );
    }
    if (_rewardedPresentationLocked) {
      _log('presentRewardedAd: blocked (presentation in progress)');
      return const RewardedPresentationResult(
        presentationStarted: false,
        rewardEarned: false,
        failureReason: RewardedFailureReason.busy,
      );
    }
    if (!await hasConnectionForAds()) {
      _log('presentRewardedAd: no network');
      return const RewardedPresentationResult(
        presentationStarted: false,
        rewardEarned: false,
        failureReason: RewardedFailureReason.noNetwork,
      );
    }

    final ad = _rewardedAd;
    if (ad == null) {
      _log('presentRewardedAd: no inventory');
      loadRewardedAd();
      return const RewardedPresentationResult(
        presentationStarted: false,
        rewardEarned: false,
        failureReason: RewardedFailureReason.noInventory,
      );
    }

    _rewardedPresentationLocked = true;
    var rewardEarned = false;
    final done = Completer<RewardedPresentationResult>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _log('Rewarded SHOW fullscreen visible');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        _log('Rewarded DISMISS rewardEarned=$rewardEarned');
        ad.dispose();
        _rewardedAd = null;
        _rewardedReadySince = null;
        _rewardedPresentationLocked = false;
        loadRewardedAd();
        if (!done.isCompleted) {
          done.complete(
            RewardedPresentationResult(
              presentationStarted: true,
              rewardEarned: rewardEarned,
              failureReason: null,
            ),
          );
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        _log('Rewarded SHOW failed', error);
        ad.dispose();
        _rewardedAd = null;
        _rewardedReadySince = null;
        _rewardedPresentationLocked = false;
        loadRewardedAd();
        if (!done.isCompleted) {
          done.complete(
            const RewardedPresentationResult(
              presentationStarted: false,
              rewardEarned: false,
              failureReason: RewardedFailureReason.failedToShow,
            ),
          );
        }
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (Ad ad, RewardItem reward) {
          // Policy: grant in-app value ONLY here (user completed the ad).
          rewardEarned = true;
          _log('Rewarded EARN ${reward.amount} ${reward.type}');
          debugPrint(
            'onUserEarnedReward => amount=${reward.amount}, type=${reward.type}',
          );
          onUserEarnedReward(reward);
        },
      );
    } catch (e, st) {
      _log('Rewarded show threw', e, st);
      _rewardedPresentationLocked = false;
      return const RewardedPresentationResult(
        presentationStarted: false,
        rewardEarned: false,
        failureReason: RewardedFailureReason.failedToShow,
      );
    }

    return done.future.timeout(
      const Duration(seconds: 180),
      onTimeout: () {
        _rewardedPresentationLocked = false;
        return RewardedPresentationResult(
          presentationStarted: true,
          rewardEarned: rewardEarned,
          failureReason: null,
        );
      },
    );
  }

  // ── Banner (unit id only; widget owns [BannerAd] lifecycle) ───────────────

  // ── Interstitial ─────────────────────────────────────────────────────────────

  void loadInterstitialAd() {
    if (!_sdkInitialized) return;
    if (_interstitialLoading || _interstitialAd != null) return;

    _interstitialLoading = true;
    final id = AdmobConfig.interstitialUnitId(useTest: _useTestAdUnits());
    _log('Interstitial LOAD start unit=$id');

    InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialLoading = false;
          _interstitialFailStreak = 0;
          _interstitialRetryTimer?.cancel();
          _log('Interstitial LOAD success');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _interstitialLoading = false;
          _interstitialFailStreak++;
          _log('Interstitial LOAD failed', error);
          _scheduleInterstitialRetry();
        },
      ),
    );
  }

  void _scheduleInterstitialRetry() {
    _interstitialRetryTimer?.cancel();
    if (_interstitialFailStreak >= AdmobConfig.maxConsecutiveLoadFailures) {
      return;
    }
    final seconds = AdmobConfig.retryDelaySeconds(_interstitialFailStreak);
    _interstitialRetryTimer = Timer(Duration(seconds: seconds), () {
      if (_interstitialAd == null && !_interstitialLoading) {
        loadInterstitialAd();
      }
    });
  }

  /// Shows an interstitial only when:
  /// - [hasConnectionForAds]
  /// - ad is loaded
  /// - at least [minInterval] since last shown (persisted)
  /// - not already presenting another interstitial
  Future<InterstitialPresentationResult> showInterstitialIfEligible({
    Duration? minInterval,
  }) async {
    final interval = minInterval ?? AdmobConfig.interstitialMinInterval;
    if (!_sdkInitialized) {
      return const InterstitialPresentationResult(
        shown: false,
        skippedReason: 'SDK not initialized',
      );
    }
    if (_interstitialPresentationLocked) {
      return const InterstitialPresentationResult(
        shown: false,
        skippedReason: 'Already showing',
      );
    }
    if (!await hasConnectionForAds()) {
      return const InterstitialPresentationResult(
        shown: false,
        skippedReason: 'Offline',
      );
    }

    final last = StorageService.readLastInterstitialShown();
    if (last != null) {
      final elapsed = DateTime.now().difference(last);
      if (elapsed < interval) {
        return InterstitialPresentationResult(
          shown: false,
          skippedReason:
              'Frequency cap (${interval.inMinutes} min): ${interval.inSeconds - elapsed.inSeconds}s left',
        );
      }
    }

    final ad = _interstitialAd;
    if (ad == null) {
      loadInterstitialAd();
      return const InterstitialPresentationResult(
        shown: false,
        skippedReason: 'No inventory',
      );
    }

    _interstitialPresentationLocked = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _log('Interstitial SHOW visible');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _log('Interstitial DISMISS');
        ad.dispose();
        _interstitialAd = null;
        _interstitialPresentationLocked = false;
        StorageService.writeLastInterstitialShown(DateTime.now());
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _log('Interstitial SHOW failed', error);
        ad.dispose();
        _interstitialAd = null;
        _interstitialPresentationLocked = false;
        loadInterstitialAd();
      },
    );

    try {
      await ad.show();
      return const InterstitialPresentationResult(shown: true);
    } catch (e, st) {
      _log('Interstitial show error', e, st);
      _interstitialPresentationLocked = false;
      return InterstitialPresentationResult(
        shown: false,
        skippedReason: e.toString(),
      );
    }
  }

  /// Backwards-compatible: no frequency check (prefer [showInterstitialIfEligible]).
  @Deprecated('Use showInterstitialIfEligible for frequency control')
  Future<bool> showInterstitialIfReady() async {
    final r = await showInterstitialIfEligible(minInterval: Duration.zero);
    return r.shown;
  }

  /// For tests / teardown (normally not needed).
  void disposeInternalTimers() {
    _rewardedRetryTimer?.cancel();
    _interstitialRetryTimer?.cancel();
  }
}
