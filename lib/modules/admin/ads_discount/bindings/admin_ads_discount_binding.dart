import 'package:get/get.dart';

import '../../inventory/bindings/inventory_binding.dart';
import '../../inventory/controllers/inventory_controller.dart';

class AdminAdsDiscountBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<InventoryController>()) {
      InventoryBinding().dependencies();
    }
  }
}
