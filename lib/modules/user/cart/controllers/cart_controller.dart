import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/services/cloudinary_service.dart';
import '../../../../app/services/order_service.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/data/models/order.dart';
import '../../../../app/data/models/product.dart';

class CartItem {
  final String id;
  final String name;
  /// Effective unit price (after product + global discounts) — updated when store/product changes.
  double unitPrice;
  final String imageUrl;
  final RxInt qty;

  CartItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.imageUrl,
    int initialQty = 1,
  }) : qty = initialQty.obs;
}

enum PaymentMethod { cod, bankTransfer }

class CartController extends GetxController {
  final selectedPayment = PaymentMethod.cod.obs;
  final receiptUploaded = false.obs;
  final receiptUrl = ''.obs;
  final isUploadingReceipt = false.obs;
  final selectedReceiptFile = Rx<File?>(null);
  final isPlacing = false.obs;

  final items = <CartItem>[].obs;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ProductService _productService = ProductService.to;
  final ImagePicker _picker = ImagePicker();

  late final Worker _priceSyncGlobal;
  late final Worker _priceSyncProducts;

  @override
  void onInit() {
    super.onInit();
    _priceSyncGlobal = ever(
      _productService.globalDiscountPercent,
      (_) => _syncCartUnitPrices(),
    );
    _priceSyncProducts = ever(
      _productService.productsVersion,
      (_) => _syncCartUnitPrices(),
    );
  }

  @override
  void onClose() {
    _priceSyncGlobal.dispose();
    _priceSyncProducts.dispose();
    super.onClose();
  }

  void _syncCartUnitPrices() {
    for (final item in items) {
      final p = _productService.findById(item.id);
      if (p != null) {
        item.unitPrice = _productService.effectivePrice(p);
      }
    }
    items.refresh();
  }

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.unitPrice * item.qty.value);

  double get total => subtotal;

  /// Sum of list prices × qty (before any discount).
  double get invoiceGrossSubtotal {
    double sum = 0;
    for (final item in items) {
      final p = _productService.findById(item.id);
      if (p != null) {
        sum += p.price * item.qty.value;
      } else {
        sum += item.unitPrice * item.qty.value;
      }
    }
    return sum;
  }

  double get invoiceProductSavingsTotal {
    double sum = 0;
    for (final item in items) {
      final p = _productService.findById(item.id);
      if (p == null) continue;
      final b = _productService.breakdown(p);
      sum += b.savingsPerUnitFromProduct * item.qty.value;
    }
    return sum;
  }

  double get invoiceGlobalSavingsTotal {
    double sum = 0;
    for (final item in items) {
      final p = _productService.findById(item.id);
      if (p == null) continue;
      final b = _productService.breakdown(p);
      sum += b.savingsPerUnitFromGlobal * item.qty.value;
    }
    return sum;
  }

  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.qty.value);

  void addToCart(ProductItem product, {int qty = 1}) {
    final existing =
        items.firstWhereOrNull((i) => i.id == product.id);
    if (existing != null) {
      existing.qty.value += qty;
    } else {
      items.add(
        CartItem(
          id: product.id,
          name: product.name,
          unitPrice: _productService.effectivePrice(product),
          imageUrl: product.imageUrl,
          initialQty: qty,
        ),
      );
    }
    Get.snackbar(
      '🛍 Added to Cart',
      '${product.name} × $qty added successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  void incrementQty(String id) {
    final item = items.firstWhereOrNull((i) => i.id == id);
    if (item != null) item.qty.value++;
  }

  void decrementQty(String id) {
    final item = items.firstWhereOrNull((i) => i.id == id);
    if (item != null && item.qty.value > 1) item.qty.value--;
  }

  void removeItem(String id) => items.removeWhere((i) => i.id == id);

  void selectPayment(PaymentMethod method) => selectedPayment.value = method;

  Future<void> uploadReceipt() async {
    if (isUploadingReceipt.value) return;
    isUploadingReceipt.value = true;

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 88,
      );
      if (picked == null) return;

      final file = File(picked.path);
      if (!await file.exists()) return;

      final url = await _cloudinaryService.uploadImage(file);
      selectedReceiptFile.value = file;
      receiptUrl.value = url;
      receiptUploaded.value = true;

      Get.snackbar(
        'Receipt Uploaded',
        'Payment receipt uploaded successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      receiptUploaded.value = false;
      receiptUrl.value = '';
      selectedReceiptFile.value = null;
      Get.snackbar(
        'Upload Failed',
        e.toString().replaceFirst('StateError: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isUploadingReceipt.value = false;
    }
  }

  void clearReceipt() {
    receiptUploaded.value = false;
    receiptUrl.value = '';
    selectedReceiptFile.value = null;
  }

  Future<void> placeOrder() async {
    if (items.isEmpty) {
      Get.snackbar(
        'Cart is empty',
        'Add some products before placing an order.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    final user = AuthService.to.currentUser.value;
    if (user == null) {
      Get.snackbar(
        'Not logged in',
        'Please sign in to place your order.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    isPlacing.value = true;

    try {
      final grossBeforeOrder = invoiceGrossSubtotal;
      final prodSavBeforeOrder = invoiceProductSavingsTotal;
      final globalSavBeforeOrder = invoiceGlobalSavingsTotal;

      final orderItems = items
          .map((i) => OrderItem(
                productName: i.name,
                quantity: i.qty.value,
                price: i.unitPrice,
              ))
          .toList();

      final isCod = selectedPayment.value == PaymentMethod.cod;
      final orderTotalVal = total;
      final receipt = receiptUrl.value.trim();
      // COD: paid on delivery → isPaid false until you confirm in admin.
      // Bank: receipt uploaded → isPaid true (payment proof received).
      final isPaid = !isCod && receipt.isNotEmpty;

      final order = Order(
        id: '',
        userId: user.uid,
        customerName: user.displayName ?? user.email ?? 'Customer',
        customerEmail: user.email ?? '',
        total: orderTotalVal,
        createdAt: DateTime.now(),
        status: OrderStatus.pending,
        isCod: isCod,
        isPaid: isPaid,
        paymentReceiptUrl: isCod ? null : (receipt.isEmpty ? null : receipt),
        items: orderItems,
      );

      final orderId = await OrderService.to.createOrder(order);

      // Clear cart
      items.clear();
      receiptUploaded.value = false;
      receiptUrl.value = '';
      selectedReceiptFile.value = null;
      selectedPayment.value = PaymentMethod.cod;

      final displayId = '#MD-${orderId.substring(0, 6).toUpperCase()}';
      final orderTotal = 'PKR ${orderTotalVal.toStringAsFixed(0)}';
      final count = orderItems.length;

      Get.offNamed(
        Routes.USER_ORDER_CONFIRM,
        arguments: {
          'orderId': displayId,
          'total': orderTotal,
          'isCod': isCod,
          'itemCount': count,
          'grossSubtotal': grossBeforeOrder,
          'productSavings': prodSavBeforeOrder,
          'globalSavings': globalSavBeforeOrder,
        },
      );
    } catch (e, st) {
      Get.snackbar(
        'Order Failed',
        'Could not place order. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      debugPrint('placeOrder error: $e\n$st');
    } finally {
      isPlacing.value = false;
    }
  }
}
