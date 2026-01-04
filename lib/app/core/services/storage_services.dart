import 'package:get_storage/get_storage.dart';

class StorageService {
  static final box = GetStorage();
  static const String tokenKey = "access_token";
  static const String refreshTokenKey = "refresh_token";

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
}