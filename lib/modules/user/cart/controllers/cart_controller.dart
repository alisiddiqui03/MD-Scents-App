import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_pages.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String imagePlaceholder;
  final RxInt qty;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePlaceholder,
    int initialQty = 1,
  }) : qty = initialQty.obs;
}

enum PaymentMethod { cod, bankTransfer }

class CartController extends GetxController {
  final selectedPayment = PaymentMethod.cod.obs;
  final receiptUploaded = false.obs;

  final items = <CartItem>[
    CartItem(
      id: '1',
      name: 'Fantast Detain Perfume',
      price: 1,
      imagePlaceholder: 'E8D5F5',
    ),
    CartItem(
      id: '2',
      name: 'Product Detain Perfume',
      price: 1,
      imagePlaceholder: 'C8E6C9',
    ),
  ].obs;

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.price * item.qty.value);

  double get total => subtotal;

  void removeItem(String id) => items.removeWhere((i) => i.id == id);

  void selectPayment(PaymentMethod method) => selectedPayment.value = method;

  void uploadReceipt() {
    receiptUploaded.value = true;
    Get.snackbar(
      '📎 Receipt',
      'Receipt upload will be wired to Firebase Storage.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  void placeOrder() {
    // Generate a simple order ID (will come from Firestore in production)
    final orderId =
        '#MD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final orderTotal = 'PKR ${total.toStringAsFixed(0)}';
    final count = items.length;
    final isCod = selectedPayment.value == PaymentMethod.cod;

    // Clear cart
    items.clear();
    receiptUploaded.value = false;
    selectedPayment.value = PaymentMethod.cod;

    // Navigate to confirmation screen — replace cart so back doesn't return to it
    Get.offNamed(
      Routes.USER_ORDER_CONFIRM,
      arguments: {
        'orderId': orderId,
        'total': orderTotal,
        'isCod': isCod,
        'itemCount': count,
      },
    );
  }
}
