import 'package:get/get.dart';

import '../controllers/user_base_controller.dart';
import '../../home/bindings/user_home_binding.dart';
import '../../cart/bindings/cart_binding.dart';
import '../../discount/bindings/discount_binding.dart';
import '../../profile/bindings/profile_binding.dart';
import '../../orders/bindings/user_orders_binding.dart';

class UserBaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserBaseController>(() => UserBaseController());
    UserHomeBinding().dependencies();
    CartBinding().dependencies();
    DiscountBinding().dependencies();
    ProfileBinding().dependencies();
    // So cancellation snackbars work without opening My Orders first.
    UserOrdersBinding().dependencies();
  }
}
