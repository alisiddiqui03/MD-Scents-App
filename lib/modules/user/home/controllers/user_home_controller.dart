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
  }

  @override
  void onClose() {
    _discountWorker.dispose();
    super.onClose();
  }
}

