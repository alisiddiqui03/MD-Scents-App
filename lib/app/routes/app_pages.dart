import 'package:get/get.dart';

import '../modules/get_profile/bindings/get_profile_binding.dart';
import '../modules/get_profile/views/get_profile_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/rewards/bindings/rewards_binding.dart';
import '../modules/rewards/views/rewards_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(name: _Paths.HOME, page: () => HomeView(), binding: HomeBinding()),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.GET_PROFILE,
      page: () => const GetProfileView(),
      binding: GetProfileBinding(),
    ),
    GetPage(
      name: _Paths.REWARDS,
      page: () => const RewardsView(),
      binding: RewardsBinding(),
    ),
  ];
}
