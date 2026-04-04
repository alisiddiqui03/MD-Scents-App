import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/services/address_service.dart';
import '../../../../app/services/firestore_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/services/cloudinary_service.dart';
import '../../../../app/services/discount_service.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/data/models/delivery_address.dart';
import '../../../../app/data/models/order.dart';
import '../../../../app/data/models/product.dart';
import '../widgets/delivery_address_picker_sheet.dart';

/// COD is only allowed when order total is strictly below this (PKR).
const double kCodMaxPkr = 10000;

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
  final DiscountService _discountService = DiscountService.to;
  final ImagePicker _picker = ImagePicker();

  late final Worker _priceSyncGlobal;
  late final Worker _priceSyncProducts;
  late final Worker _itemsDeliveryWorker;
  late final Worker _discountWorker;
  late final Worker _authWorker;

  /// Bumps so checkout UI can react to delivery field edits.
  final deliveryInputVersion = 0.obs;

  /// Delivery fields (phone + address required to place order).
  final deliveryPhoneController = TextEditingController();
  final deliveryStreetController = TextEditingController();
  final deliveryCityController = TextEditingController();
  final deliveryPostalController = TextEditingController();

  /// One silent prefill per cart fill (empty → has items again) — no bottom sheet.
  bool _didSilentPrefillThisFill = false;

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
    _itemsDeliveryWorker = ever(items, (_) {
      if (items.isEmpty) {
        _didSilentPrefillThisFill = false;
        return;
      }
      if (_didSilentPrefillThisFill) return;
      Future.microtask(_silentPrefillDeliveryFromFirestore);
    });
    _authWorker = ever(AuthService.to.currentUser, (_) {
      if (items.isEmpty || _didSilentPrefillThisFill) return;
      Future.microtask(_silentPrefillDeliveryFromFirestore);
    });
    _discountWorker = ever(
      _discountService.currentDiscountPercent,
      (_) => _enforceCodRuleFromCartChange(),
    );
  }

  void notifyDeliveryChanged() => deliveryInputVersion.value++;

  /// Prefills default saved address only — no sheet. Address picker is on cart via "Saved / new".
  Future<void> _silentPrefillDeliveryFromFirestore() async {
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null || items.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 150));

    final addresses = await AddressService.to.fetchAddressesOnce(uid);
    _applyRecommendedDelivery(addresses);
    notifyDeliveryChanged();
    if (items.isNotEmpty) _didSilentPrefillThisFill = true;
  }

  @override
  void onClose() {
    _priceSyncGlobal.dispose();
    _priceSyncProducts.dispose();
    _itemsDeliveryWorker.dispose();
    _discountWorker.dispose();
    _authWorker.dispose();
    deliveryPhoneController.dispose();
    deliveryStreetController.dispose();
    deliveryCityController.dispose();
    deliveryPostalController.dispose();
    super.onClose();
  }

  void _clearDeliveryFields() {
    deliveryPhoneController.clear();
    deliveryStreetController.clear();
    deliveryCityController.clear();
    deliveryPostalController.clear();
  }

  void _applyFromSaved(DeliveryAddress a) {
    deliveryPhoneController.text = a.phone;
    deliveryStreetController.text = a.street;
    deliveryCityController.text = a.city;
    deliveryPostalController.text = a.postalCode;
  }

  /// Prefill from Firestore `users/{uid}/addresses` — default flag, else first.
  void _applyRecommendedDelivery(List<DeliveryAddress> addresses) {
    if (addresses.isNotEmpty) {
      final def = addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => addresses.first,
      );
      _applyFromSaved(def);
      return;
    }
    _clearDeliveryFields();
  }

  int _detectCurrentOptionIndex(List<DeliveryAddress> addresses) {
    final p = deliveryPhoneController.text.trim();
    final st = deliveryStreetController.text.trim();
    for (var i = 0; i < addresses.length; i++) {
      final a = addresses[i];
      if (p == a.phone.trim() && st == a.street.trim()) {
        return i;
      }
    }
    return addresses.length;
  }

  Future<void> _showDeliveryAddressSheet({
    required List<DeliveryAddress> addresses,
  }) async {
    final initialIndex = _detectCurrentOptionIndex(addresses);
    final ctx = Get.context ?? Get.key.currentContext;
    if (ctx == null) return;

    await showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DeliveryAddressPickerSheet(
        savedAddresses: addresses,
        initialIndex: initialIndex,
        onPickSaved: _applyFromSaved,
        onPickNew: _clearDeliveryFields,
      ),
    );
    notifyDeliveryChanged();
  }

  /// Opens the address picker from cart only (Saved / new).
  Future<void> openDeliveryAddressPicker() async {
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) {
      Get.snackbar(
        'Sign in required',
        'Sign in to use saved addresses from your account.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    final addresses = await AddressService.to.fetchAddressesOnce(uid);

    await _showDeliveryAddressSheet(addresses: addresses);
  }

  void _enforceCodRuleFromCartChange() {
    if (selectedPayment.value != PaymentMethod.cod) return;
    if (total < kCodMaxPkr) return;
    selectedPayment.value = PaymentMethod.bankTransfer;
  }

  void _syncCartUnitPrices() {
    for (final item in items) {
      final p = _productService.findById(item.id);
      if (p != null) {
        item.unitPrice = _productService.effectivePrice(p);
      }
    }
    items.refresh();
    _enforceCodRuleFromCartChange();
  }

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.unitPrice * item.qty.value);

  double get userDiscountPercent =>
      _discountService.currentDiscountPercent.value.clamp(0, 20).toDouble();

  double get userDiscountAmount => subtotal * (userDiscountPercent / 100);

  double get total => (subtotal - userDiscountAmount).clamp(0, double.infinity);

  /// Place Order only when cart has items, user is signed in, delivery is filled,
  /// COD is valid for total, and bank transfer has an uploaded receipt URL.
  bool get isReadyToPlaceOrder {
    if (isPlacing.value) return false;
    if (AuthService.to.currentUser.value == null) return false;
    if (items.isEmpty) return false;
    final phone = deliveryPhoneController.text.trim();
    final street = deliveryStreetController.text.trim();
    if (phone.isEmpty || street.isEmpty) return false;
    if (selectedPayment.value == PaymentMethod.cod && total >= kCodMaxPkr) {
      return false;
    }
    if (selectedPayment.value == PaymentMethod.bankTransfer) {
      if (!receiptUploaded.value) return false;
      if (receiptUrl.value.trim().isEmpty) return false;
    }
    return true;
  }

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

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.qty.value);

  void addToCart(ProductItem product, {int qty = 1}) {
    if (qty < 1) return;

    final cap = product.stock;
    if (cap <= 0) {
      Get.snackbar(
        'Out of stock',
        '${product.name} is not available.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final existing = items.firstWhereOrNull((i) => i.id == product.id);
    final inCart = existing?.qty.value ?? 0;
    final room = cap - inCart;
    if (room <= 0) {
      Get.snackbar(
        'Stock limit',
        'You already have the maximum ($cap) for ${product.name}.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final add = qty > room ? room : qty;
    if (existing != null) {
      existing.qty.value += add;
    } else {
      items.add(
        CartItem(
          id: product.id,
          name: product.name,
          unitPrice: _productService.effectivePrice(product),
          imageUrl: product.imageUrl,
          initialQty: add,
        ),
      );
    }

    if (add < qty) {
      Get.snackbar(
        'Limited stock',
        'Only $add of ${product.name} added ($cap in stock).',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.info_outline, color: Colors.white),
      );
    } else {
      Get.snackbar(
        '🛍 Added to Cart',
        '${product.name} × $add added successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
    }
    _enforceCodRuleFromCartChange();
  }

  void incrementQty(String id) {
    final item = items.firstWhereOrNull((i) => i.id == id);
    if (item == null) return;
    final p = _productService.findById(id);
    if (p == null) return;
    final cap = p.stock;
    if (item.qty.value >= cap) {
      Get.snackbar(
        'Stock limit',
        'Maximum available is $cap.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    item.qty.value++;
    _enforceCodRuleFromCartChange();
  }

  void decrementQty(String id) {
    final item = items.firstWhereOrNull((i) => i.id == id);
    if (item != null && item.qty.value > 1) {
      item.qty.value--;
      _enforceCodRuleFromCartChange();
    }
  }

  void removeItem(String id) {
    items.removeWhere((i) => i.id == id);
    _enforceCodRuleFromCartChange();
  }

  void selectPayment(PaymentMethod method) {
    if (method == PaymentMethod.cod && total >= kCodMaxPkr) {
      selectedPayment.value = PaymentMethod.bankTransfer;
      return;
    }
    selectedPayment.value = method;
  }

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

    final phone = deliveryPhoneController.text.trim();
    final street = deliveryStreetController.text.trim();
    if (phone.isEmpty || street.isEmpty) {
      Get.snackbar(
        'Delivery details required',
        'Please enter your phone number and delivery address.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final wantsCod = selectedPayment.value == PaymentMethod.cod;
    if (wantsCod && total >= kCodMaxPkr) {
      return;
    }

    isPlacing.value = true;

    try {
      final grossBeforeOrder = invoiceGrossSubtotal;
      final prodSavBeforeOrder = invoiceProductSavingsTotal;
      final globalSavBeforeOrder = invoiceGlobalSavingsTotal;
      final userSavBeforeOrder = userDiscountAmount;

      final orderItems = items
          .map(
            (i) => OrderItem(
              productName: i.name,
              quantity: i.qty.value,
              price: i.unitPrice,
            ),
          )
          .toList();

      final isCod = wantsCod;
      final orderTotalVal = total;
      final receipt = receiptUrl.value.trim();
      final city = deliveryCityController.text.trim();
      final postal = deliveryPostalController.text.trim();
      // COD: paid on delivery → isPaid false until you confirm in admin.
      // Bank: receipt uploaded → isPaid true (payment proof received).
      final isPaid = !isCod && receipt.isNotEmpty;

      final orderRef = FirestoreService.usersOrdersRef(user.uid).doc();
      final placedAt = DateTime.now();

      final order = Order(
        id: orderRef.id,
        userId: user.uid,
        customerName: user.displayName ?? user.email ?? 'Customer',
        customerEmail: user.email ?? '',
        total: orderTotalVal,
        createdAt: placedAt,
        status: OrderStatus.pending,
        isCod: isCod,
        isPaid: isPaid,
        paymentReceiptUrl: isCod ? null : (receipt.isEmpty ? null : receipt),
        items: orderItems,
        deliveryPhone: phone,
        deliveryStreet: street,
        deliveryCity: city,
        deliveryPostalCode: postal,
      );

      await FirestoreService.instance.runTransaction((txn) async {
        for (final item in items) {
          final pref = FirestoreService.productsCollection.doc(item.id);
          final snap = await txn.get(pref);
          if (!snap.exists) {
            throw StateError('Product "${item.name}" is no longer available.');
          }
          final stock = (snap.data()?['stock'] as num?)?.toInt() ?? 0;
          if (stock < item.qty.value) {
            throw StateError(
              'Not enough stock for "${item.name}". Only $stock left.',
            );
          }
        }
        for (final item in items) {
          txn.update(FirestoreService.productsCollection.doc(item.id), {
            'stock': FieldValue.increment(-item.qty.value),
          });
        }
        txn.set(orderRef, order.toMap());
      });

      await FirestoreService.usersCollection.doc(user.uid).set({
        'lastDeliveryPhone': phone,
        'lastDeliveryStreet': street,
        'lastDeliveryCity': city,
        'lastDeliveryPostalCode': postal,
      }, SetOptions(merge: true));

      final orderId = orderRef.id;

      // Any active discount is considered consumed on successful purchase.
      await _discountService.consumeDiscountOnPurchaseIfAny();

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
          'placedAt': placedAt,
          'grossSubtotal': grossBeforeOrder,
          'productSavings': prodSavBeforeOrder,
          'globalSavings': globalSavBeforeOrder,
          'userSavings': userSavBeforeOrder,
        },
      );
    } catch (e, st) {
      final message = e is StateError
          ? e.message
          : 'Could not place order. Please try again.';
      Get.snackbar(
        'Order Failed',
        message,
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
