import 'package:get/get.dart';

import '../controllers/admin_referrals_controller.dart';

class AdminReferralsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminReferralsController>(() => AdminReferralsController());
  }
}
