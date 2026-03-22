import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/services/auth_service.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/utils/admin_snackbar.dart';

class AdminSettingsController extends GetxController {
  final ProductService _productService = ProductService.to;

  final discountFieldController = TextEditingController();
  final lowStockFieldController = TextEditingController();
  final isSaving = false.obs;
  final isSavingLowStock = false.obs;
  final isSigningOut = false.obs;

  double get globalDiscount => _productService.globalDiscountPercent.value;

  @override
  void onInit() {
    super.onInit();
    discountFieldController.text = globalDiscount.toStringAsFixed(0);
    lowStockFieldController.text =
        _productService.lowStockThreshold.value.toString();
    ever<double>(_productService.globalDiscountPercent, (value) {
      discountFieldController.text = value.toStringAsFixed(0);
    });
    ever<int>(_productService.lowStockThreshold, (value) {
      lowStockFieldController.text = value.toString();
    });
  }

  @override
  void onClose() {
    discountFieldController.dispose();
    lowStockFieldController.dispose();
    super.onClose();
  }

  Future<void> applyDiscountFromField() async {
    final v = double.tryParse(discountFieldController.text.trim()) ?? 0;
    isSaving.value = true;
    try {
      await _productService.setGlobalDiscountPercent(v);
      discountFieldController.text =
          _productService.globalDiscountPercent.value.toStringAsFixed(0);
      AdminSnackbar.success(
        'Discount updated',
        'Global discount is now ${_productService.globalDiscountPercent.value.toStringAsFixed(0)}%.',
      );
    } catch (e) {
      AdminSnackbar.error('Could not save discount', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> applyLowStockFromField() async {
    final raw = int.tryParse(lowStockFieldController.text.trim());
    if (raw == null) {
      AdminSnackbar.error('Invalid value', 'Enter a whole number (e.g. 5).');
      return;
    }
    isSavingLowStock.value = true;
    try {
      await _productService.setLowStockThreshold(raw);
      lowStockFieldController.text =
          _productService.lowStockThreshold.value.toString();
      AdminSnackbar.success(
        'Low stock threshold saved',
        'Products with stock ≤ ${_productService.lowStockThreshold.value} show as low stock.',
      );
    } catch (e) {
      AdminSnackbar.error('Could not save', e.toString());
    } finally {
      isSavingLowStock.value = false;
    }
  }

  Future<void> signOut() async {
    if (isSigningOut.value) return;
    isSigningOut.value = true;
    try {
      await AuthService.to.signOut();
      Get.offAllNamed(Routes.AUTH);
    } catch (e) {
      AdminSnackbar.error('Sign out failed', e.toString());
    } finally {
      isSigningOut.value = false;
    }
  }
}
