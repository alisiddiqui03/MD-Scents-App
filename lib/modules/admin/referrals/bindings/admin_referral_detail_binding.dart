import 'package:get/get.dart';

import '../controllers/admin_referral_detail_controller.dart';

class AdminReferralDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminReferralDetailController>(
      () => AdminReferralDetailController(),
    );
  }
}
