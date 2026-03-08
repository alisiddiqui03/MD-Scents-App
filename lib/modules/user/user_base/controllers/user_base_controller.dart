import 'package:flutter_application_1/app/routes/app_pages.dart';
import 'package:get/get.dart';


class UserBaseController extends GetxController {
  final currentIndex = 0.obs;

  final tabs = const [
    Routes.USER_HOME,
    Routes.USER_CART,
    Routes.USER_DISCOUNT,
    Routes.USER_PROFILE,
  ];

  void onTabSelected(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }
}

