import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/models/product.dart';
import '../../../../app/services/discount_service.dart';
import '../../../../app/services/product_service.dart';

class UserHomeController extends GetxController {
  final ProductService _productService = ProductService.to;
  final DiscountService _discountService = DiscountService.to;

  final currentBannerIndex = 0.obs;
  final discountPercent = 5.0.obs;

  /// Used by All Products filter strip (not shown on home).
  final selectedCategoryIndex = 0.obs;

  List<BannerData> get banners => _productService.banners;
  List<CategoryItem> get categories => _productService.categories;
  List<ProductItem> get latestProducts => _productService.latestProducts;
  List<ProductItem> get featuredProducts => _productService.featuredProducts;

  final pageController = PageController();
  Timer? _timer;

  void onBannerChanged(int index) => currentBannerIndex.value = index;
  void onCategorySelected(int index) => selectedCategoryIndex.value = index;

  late final Worker _discountWorker;

  @override
  void onInit() {
    super.onInit();
    discountPercent.value = _discountService.currentDiscountPercent.value;
    _discountWorker = ever(
      _discountService.currentDiscountPercent,
      (v) => discountPercent.value = (v as num).toDouble(),
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (banners.isNotEmpty && pageController.hasClients) {
        int nextPage = currentBannerIndex.value + 1;
        if (nextPage >= banners.length) {
          nextPage = 0;
        }
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    _discountWorker.dispose();
    super.onClose();
  }
}
