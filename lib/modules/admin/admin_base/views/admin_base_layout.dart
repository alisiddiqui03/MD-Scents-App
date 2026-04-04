import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_base_controller.dart';
import '../../dashboard/views/admin_dashboard_view.dart';
import '../../inventory/views/inventory_view.dart';
import '../../orders/views/orders_view.dart';
import '../../settings/views/admin_settings_view.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/services/admin_order_alert_service.dart';

class AdminBaseLayout extends GetView<AdminBaseController> {
  const AdminBaseLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.currentIndex.value;

      return Scaffold(
        body: IndexedStack(
          index: index,
          children: const [
            AdminDashboardView(),
            InventoryView(),
            OrdersView(),
            AdminSettingsView(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed(Routes.ADMIN_UPLOAD_PRODUCT),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: controller.onTabSelected,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                label: 'Inventory',
              ),
              BottomNavigationBarItem(
                icon: Obx(() {
                  final n = AdminOrderAlertService.to.unseenOrderCount.value;
                  return Badge(
                    isLabelVisible: n > 0,
                    label: Text(
                      n > 9 ? '9+' : '$n',
                      style: const TextStyle(fontSize: 10),
                    ),
                    child: const Icon(Icons.receipt_long_outlined),
                  );
                }),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      );
    });
  }
}
