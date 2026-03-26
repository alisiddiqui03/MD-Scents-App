import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';
import '../services/product_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Anchored adaptive banner for the Offers screen — loads once, disposes on exit.
///
/// Failures show a non-intrusive fallback with retry (AdMob policy–friendly UX).
class DiscountBannerAd extends StatefulWidget {
  const DiscountBannerAd({super.key});

  @override
  State<DiscountBannerAd> createState() => _DiscountBannerAdState();
}

class _DiscountBannerAdState extends State<DiscountBannerAd> {
  BannerAd? _banner;
  _BannerPhase _phase = _BannerPhase.idle;
  Worker? _adsWorker;
  bool _loadScheduled = false;

  @override
  void initState() {
    super.initState();
    _adsWorker = ever(
      ProductService.to.adsRewardEnabled,
      (dynamic enabled) {
        if (enabled == false) {
          _disposeBanner();
          if (mounted) setState(() => _phase = _BannerPhase.idle);
        } else if (_banner == null) {
          _scheduleLoad();
        }
      },
    );
    _scheduleLoad();
  }

  void _scheduleLoad() {
    if (_loadScheduled) return;
    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;
      _load();
    });
  }

  Future<void> _load() async {
    if (!mounted || !Get.isRegistered<ProductService>()) return;
    if (!ProductService.to.adsRewardEnabled.value) return;

    if (_banner != null) return;

    setState(() => _phase = _BannerPhase.loading);

    final w = MediaQuery.sizeOf(context).width.truncate();
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(w);
    if (!mounted) return;

    late final BannerAd ad;
    ad = BannerAd(
      adUnitId: AdService.instance.bannerAdUnitId,
      size: size ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() {
            _banner = ad;
            _phase = _BannerPhase.ready;
          });
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          if (mounted) setState(() => _phase = _BannerPhase.failed);
        },
      ),
    );

    await ad.load();
    if (!mounted) {
      ad.dispose();
      return;
    }
  }

  void _disposeBanner() {
    _banner?.dispose();
    _banner = null;
  }

  @override
  void dispose() {
    _adsWorker?.dispose();
    _disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!ProductService.to.adsRewardEnabled.value) {
        return const SizedBox.shrink();
      }

      switch (_phase) {
        case _BannerPhase.idle:
        case _BannerPhase.loading:
          return SizedBox(
            height: 52,
            child: Center(
              child: Text(
                'Loading ad…',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
            ),
          );
        case _BannerPhase.failed:
          return _FallbackBar(
            message: 'Ad not available. Check connection or try again.',
            onRetry: _scheduleLoad,
          );
        case _BannerPhase.ready:
          final ad = _banner;
          if (ad == null) {
            return const SizedBox(height: 50);
          }
          return ColoredBox(
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            ),
          );
      }
    });
  }
}

enum _BannerPhase { idle, loading, ready, failed }

class _FallbackBar extends StatelessWidget {
  const _FallbackBar({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
