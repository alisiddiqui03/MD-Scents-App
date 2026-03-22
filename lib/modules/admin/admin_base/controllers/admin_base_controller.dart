import 'package:get/get.dart';

class AdminBaseController extends GetxController {
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final tab = args['tab'];
      if (tab is int && tab >= 0 && tab <= 3) {
        currentIndex.value = tab;
      }
    }
  }

  void onTabSelected(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }
}

