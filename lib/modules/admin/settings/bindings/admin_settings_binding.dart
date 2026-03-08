import 'package:get/get.dart';

import '../controllers/admin_settings_controller.dart';

class AdminSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminSettingsController>(() => AdminSettingsController());
  }
}

