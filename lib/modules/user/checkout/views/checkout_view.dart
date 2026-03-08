import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/checkout_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'CHECKOUT',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Placeholder Checkout Screen',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Future work: COD, Bank Transfer with receipt upload, and payment status summary.',
              style: AppTextStyles.bodyMedium,
            ),
            const Spacer(),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isProcessing.value ? null : () {},
                child: controller.isProcessing.value
                    ? const CircularProgressIndicator()
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

