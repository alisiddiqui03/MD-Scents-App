import 'package:get/get.dart';

import '../controllers/user_orders_controller.dart';

class UserOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserOrdersController>(() => UserOrdersController());
  }
}
