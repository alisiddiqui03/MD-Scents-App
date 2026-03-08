import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_base_controller.dart';
import '../../dashboard/views/admin_dashboard_view.dart';
import '../../inventory/views/inventory_view.dart';
import '../../orders/views/orders_view.dart';
import '../../settings/views/admin_settings_view.dart';

class AdminBaseLayout extends GetView<AdminBaseController> {
  const AdminBaseLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
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
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: controller.onTabSelected,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                label: 'Inventory',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}

