import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/services/auth_service.dart';
import 'app/services/product_service.dart';
import 'app/services/order_service.dart';
import 'app/services/ad_service.dart';
import 'app/services/discount_service.dart';
import 'app/services/wishlist_service.dart';
import 'app/services/review_service.dart';
import 'app/services/address_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AdService.instance.init();

  // Initialize global services before running the app.
  Get.put<ProductService>(ProductService());
  Get.put<OrderService>(OrderService());
  Get.put<WishlistService>(WishlistService());
  Get.put<ReviewService>(ReviewService());
  Get.put<AddressService>(AddressService());
  await Get.putAsync<AuthService>(() async => AuthService().init());
  Get.put<DiscountService>(DiscountService());

  runApp(const MdScentsApp());
}

class MdScentsApp extends StatelessWidget {
  const MdScentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MD Scents',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Force light theme for now so admin/user UIs
      // look consistent and backgrounds don't turn black in release.
      themeMode: ThemeMode.light,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
