import 'package:get_storage/get_storage.dart';

class StorageService {
  static final box = GetStorage();
  static const String tokenKey = "access_token";
  static const String refreshTokenKey = "refresh_token";

  /// User "Offers" screen boosted discount % (persists across sessions).
  static const String offerDiscountPercentKey = 'md_offer_discount_percent';

  /// Last time an interstitial was shown (epoch ms) — frequency capping.
  static const String lastInterstitialShownMsKey = 'md_ad_last_interstitial_ms';

  static Future<void> saveTokens(String access, String refresh) async {
    await box.write(tokenKey, access);
    await box.write(refreshTokenKey, refresh);
  }

  static String? get token => box.read(tokenKey);
  static String? get refreshToken => box.read(refreshTokenKey);

  static Future<void> clearTokens() async {
    await box.remove(tokenKey);
    await box.remove(refreshTokenKey);
  }

  static double? readOfferDiscountPercent() {
    final v = box.read(offerDiscountPercentKey);
    if (v is num) return v.toDouble();
    return null;
  }

  static Future<void> writeOfferDiscountPercent(double value) async {
    await box.write(offerDiscountPercentKey, value);
  }

  static DateTime? readLastInterstitialShown() {
    final v = box.read(lastInterstitialShownMsKey);
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v);
    }
    return null;
  }

  static Future<void> writeLastInterstitialShown(DateTime time) async {
    await box.write(lastInterstitialShownMsKey, time.millisecondsSinceEpoch);
  }
}