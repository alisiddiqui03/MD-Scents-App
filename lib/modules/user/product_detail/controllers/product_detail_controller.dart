import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/models/app_user.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/services/wishlist_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/data/models/product.dart';
import '../../cart/controllers/cart_controller.dart';

class ProductDetailController extends GetxController {
  final quantity = 1.obs;
  late final ProductItem product;
  late final PageController imagePageController;
  final currentImageIndex = 0.obs;
  final isWishlisted = false.obs;
  final wishlistCount = 0.obs;
  StreamSubscription<bool>? _wishlistedSub;
  StreamSubscription<int>? _wishlistCountSub;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String? ?? '1';

    product = ProductService.to.findById(id) ??
        ProductService.to.latestProducts.first;

    imagePageController = PageController();

    _bindWishlist(AuthService.to.currentUser.value?.uid);
    ever<AppUser?>(AuthService.to.currentUser, (user) {
      _bindWishlist(user?.uid);
    });
  }

  void _bindWishlist(String? uid) {
    _wishlistedSub?.cancel();
    _wishlistCountSub?.cancel();
    _wishlistedSub = null;
    _wishlistCountSub = null;
    if (uid == null) {
      isWishlisted.value = false;
      wishlistCount.value = 0;
      return;
    }
    _wishlistedSub =
        WishlistService.to.isWishlistedStream(uid, product.id).listen((v) {
      isWishlisted.value = v;
    });
    _wishlistCountSub =
        WishlistService.to.wishlistCountStream(uid).listen((c) {
      wishlistCount.value = c;
    });
  }

  void increment() {
    if (quantity.value < 20) quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  /// Images shown in the gallery (multi + legacy single URL).
  List<String> get galleryUrls {
    final u = product.imageUrls;
    if (u.isNotEmpty) return u;
    if (product.imageUrl.isNotEmpty) return [product.imageUrl];
    return [];
  }

  void onGalleryPageChanged(int index) {
    currentImageIndex.value = index;
  }

  void addToCart() {
    final cart = Get.find<CartController>();
    cart.addToCart(product, qty: quantity.value);
  }

  Future<void> toggleWishlist() async {
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) {
      Get.snackbar(
        'Login Required',
        'Please sign in to use wishlist.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    if (isWishlisted.value) {
      await WishlistService.to.removeFromWishlist(uid, product.id);
      Get.snackbar(
        'Removed',
        '${product.name} removed from wishlist.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );
    } else {
      await WishlistService.to.addToWishlist(uid, product);
      Get.snackbar(
        'Saved',
        '${product.name} added to wishlist.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    imagePageController.dispose();
    _wishlistedSub?.cancel();
    _wishlistCountSub?.cancel();
    super.onClose();
  }
}
