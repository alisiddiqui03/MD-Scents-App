import 'package:get/get.dart';

import '../controllers/vip_dashboard_controller.dart';

class VipDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VipDashboardController>(() => VipDashboardController());
  }
}

