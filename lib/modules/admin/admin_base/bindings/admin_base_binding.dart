import 'package:get/get.dart';

import '../controllers/admin_base_controller.dart';
import '../../dashboard/bindings/admin_dashboard_binding.dart';
import '../../inventory/bindings/inventory_binding.dart';
import '../../orders/bindings/orders_binding.dart';
import '../../settings/bindings/admin_settings_binding.dart';

class AdminBaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminBaseController>(() => AdminBaseController());
    AdminDashboardBinding().dependencies();
    InventoryBinding().dependencies();
    OrdersBinding().dependencies();
    AdminSettingsBinding().dependencies();
  }
}

