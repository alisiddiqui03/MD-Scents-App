import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_dashboard_controller.dart';
import '../../../../app/theme/app_text_styles.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Placeholder Dashboard',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                'Total sales: \$${controller.totalSales.value.toStringAsFixed(2)}',
                style: AppTextStyles.bodyLarge,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                'Total orders: ${controller.totalOrders.value}',
                style: AppTextStyles.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

