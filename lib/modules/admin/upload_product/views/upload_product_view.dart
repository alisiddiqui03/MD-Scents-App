import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/upload_product_controller.dart';
import '../../../../app/theme/app_text_styles.dart';

class UploadProductView extends GetView<UploadProductController> {
  const UploadProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Placeholder Upload Product Screen',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isSaving.value ? null : () {},
                child: controller.isSaving.value
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

