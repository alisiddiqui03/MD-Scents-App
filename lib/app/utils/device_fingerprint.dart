import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Best-effort stable-ish id for referral fraud checks (not cryptographically strong).
Future<String> getReferralDeviceFingerprint() async {
  final plugin = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      final a = await plugin.androidInfo;
      return 'android_${a.id}';
    }
    if (Platform.isIOS) {
      final i = await plugin.iosInfo;
      return 'ios_${i.identifierForVendor ?? "unknown"}';
    }
  } catch (_) {
    // ignore
  }
  return 'unknown';
}
