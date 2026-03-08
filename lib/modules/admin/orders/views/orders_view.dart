import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/orders_controller.dart';
import '../../../../app/theme/app_text_styles.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Placeholder Orders Screen',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                'Total orders: ${controller.totalOrders.value}',
                style: AppTextStyles.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Future work: order status lifecycle (Pending, Packed, Shipped, Delivered, Cancelled).',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

