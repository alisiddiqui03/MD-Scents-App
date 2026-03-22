import 'dart:async';

import 'package:get/get.dart';

import '../../../../app/data/models/wishlist_item.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/services/wishlist_service.dart';
import '../../cart/controllers/cart_controller.dart';

class WishlistController extends GetxController {
  final items = <WishlistItem>[].obs;
  final isLoading = true.obs;

  StreamSubscription<List<WishlistItem>>? _sub;

  String? get _uid => AuthService.to.currentUser.value?.uid;

  @override
  void onInit() {
    super.onInit();
    final uid = _uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }
    _sub = WishlistService.to.wishlistStream(uid).listen((data) {
      items.assignAll(data);
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> remove(String productId) async {
    final uid = _uid;
    if (uid == null) return;
    await WishlistService.to.removeFromWishlist(uid, productId);
  }

  Future<void> clearAll() async {
    final uid = _uid;
    if (uid == null) return;
    await WishlistService.to.clearWishlist(uid);
  }

  void addToCart(WishlistItem item) {
    final product = ProductService.to.findById(item.productId);
    if (product == null) return;
    Get.find<CartController>().addToCart(product, qty: 1);
  }

  Future<void> refreshWishlist() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final list = await WishlistService.to.fetchWishlistOnce(uid);
      items.assignAll(list);
    } catch (_) {}
  }
}
