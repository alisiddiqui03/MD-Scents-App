import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../user/home/controllers/user_home_controller.dart';
import '../../../../app/theme/app_colors.dart';

class ProductDetailController extends GetxController {
  final quantity = 1.obs;
  late final ProductItem product;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String? ?? '1';

    final homeCtrl = Get.find<UserHomeController>();
    product = homeCtrl.latestProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => homeCtrl.latestProducts.first,
    );
  }

  void increment() {
    if (quantity.value < 20) quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  void addToCart() {
    Get.snackbar(
      '🛍 Added to Cart',
      '${product.name} × ${quantity.value} added successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }
}
