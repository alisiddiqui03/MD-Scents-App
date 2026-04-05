import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'core/constants/app_constants.dart';
import 'firebase_options.dart';
import 'services/onesignal_service.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/services/auth_service.dart';
import 'app/services/user_order_stream_service.dart';
import 'app/services/product_service.dart';
import 'app/services/order_service.dart';
import 'app/services/ad_service.dart';
import 'app/services/discount_service.dart';
import 'app/services/wallet_service.dart';
import 'app/services/referral_service.dart';
import 'app/services/admin_referrals_service.dart';
import 'app/services/wishlist_service.dart';
import 'app/services/review_service.dart';
import 'app/services/address_service.dart';
import 'app/services/admin_order_alert_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await OneSignal.initialize(oneSignalAppId);
  await OneSignal.Notifications.requestPermission(true);
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    event.preventDefault();
    event.notification.display();
  });

  await AdService.instance.init();

  // Initialize global services before running the app.
  // Auth before OrderService: admin collection-group orders query requires isAdmin.
  await Get.putAsync<AuthService>(() async => AuthService().init());

  final existingUid = FirebaseAuth.instance.currentUser?.uid;
  if (existingUid != null) {
    unawaited(_syncPushAfterColdStart(existingUid));
  }

  Get.put<ProductService>(ProductService());
  Get.put<OrderService>(OrderService());
  Get.put<UserOrderStreamService>(UserOrderStreamService(), permanent: true);
  Get.put<AdminOrderAlertService>(AdminOrderAlertService());
  Get.put<WishlistService>(WishlistService());
  Get.put<ReviewService>(ReviewService());
  Get.put<AddressService>(AddressService());
  Get.put<DiscountService>(DiscountService());
  Get.put<WalletService>(WalletService());
  Get.put<ReferralService>(ReferralService());
  Get.put<AdminReferralsService>(AdminReferralsService());

  runApp(const MdScentsApp());
}

Future<void> _syncPushAfterColdStart(String uid) async {
  try {
    await OneSignalService.savePlayerIdToFirestore(uid);
    await Future<void>.delayed(const Duration(seconds: 2));
    await OneSignalService.savePlayerIdToFirestore(uid);
  } catch (e, st) {
    debugPrint('_syncPushAfterColdStart: $e\n$st');
  }
}

class MdScentsApp extends StatelessWidget {
  const MdScentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MD Scents',
      debugShowCheckedModeBanner: false,
      // Ensure Get.snackbar / dialogs use the same navigator in debug & release.
      navigatorKey: Get.key,
      theme: AppTheme.light,
      // Force light theme for now so admin/user UIs
      // look consistent and backgrounds don't turn black in release.
      themeMode: ThemeMode.light,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
