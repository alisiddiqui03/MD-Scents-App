import 'package:get/get.dart';

import '../controllers/get_profile_controller.dart';

class GetProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetProfileController>(
      () => GetProfileController(),
    );
  }
}
