import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/inventory_controller.dart';
import '../../../../app/theme/app_text_styles.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Placeholder Inventory Screen',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                'Total items in stock: ${controller.totalItems.value}',
                style: AppTextStyles.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

