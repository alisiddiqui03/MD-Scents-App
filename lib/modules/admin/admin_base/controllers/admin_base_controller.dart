import 'package:get/get.dart';

class AdminBaseController extends GetxController {
  final currentIndex = 0.obs;

  void onTabSelected(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }
}

