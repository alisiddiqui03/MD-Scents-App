import 'package:get/get.dart';

import '../controllers/admin_vip_management_controller.dart';

class AdminVipManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminVipManagementController>(() => AdminVipManagementController());
  }
}

