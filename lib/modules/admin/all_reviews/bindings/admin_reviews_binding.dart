import 'package:get/get.dart';

import '../controllers/admin_reviews_controller.dart';

class AdminReviewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminReviewsController>(() => AdminReviewsController());
  }
}
