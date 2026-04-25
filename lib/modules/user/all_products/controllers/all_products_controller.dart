import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/models/product.dart';
import '../../../../app/services/product_service.dart';

enum AllProductsSort {
  newest,
  priceLowHigh,
  priceHighLow,
  nameAZ,
}

class AllProductsController extends GetxController {
  final ProductService _productService = ProductService.to;

  /// Fixed PKR range for filter slider (0 → 1 lac).
  static const RangeValues kPriceBounds = RangeValues(0, 100000);

  // ── Category ─────────────────────────────────────────────────────────────────
  /// `null` = show all categories.
  final selectedCategory = Rxn<String>();

  // ── Price ─────────────────────────────────────────────────────────────────────
  /// When true, only products whose effective price falls in [appliedPriceRange].
  final priceFilterActive = false.obs;

  /// Used when [priceFilterActive] is true (slider selection).
  final appliedPriceRange = kPriceBounds.obs;

  // ── Size (ml) ────────────────────────────────────────────────────────────────
  /// `null` = show all sizes.
  final selectedSize = Rxn<int>();

  // ── Brand ─────────────────────────────────────────────────────────────────────
  /// `null` = show all brands.
  final selectedBrand = Rxn<String>();

  // ── Gender ───────────────────────────────────────────────────────────────────
  /// `null` = show all genders.
  final selectedGender = Rxn<String>();

  // ── Sort ──────────────────────────────────────────────────────────────────────
  final sort = AllProductsSort.newest.obs;

  /// Slider min/max (always 0–100,000 PKR).
  RangeValues get catalogPriceRange => kPriceBounds;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      // Support navigation with pre-selected brand
      final brand = args['brand'] as String?;
      if (brand != null && brand.isNotEmpty) {
        selectedBrand.value = brand;
      }
      // Support navigation with pre-selected size
      final size = args['size'] as int?;
      if (size != null) {
        selectedSize.value = size;
      }
      // Support navigation with pre-selected gender
      final gender = args['gender'] as String?;
      if (gender != null && gender.isNotEmpty) {
        selectedGender.value = gender;
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    appliedPriceRange.value = catalogPriceRange;
  }

  // ── Filtered products ─────────────────────────────────────────────────────────

  List<ProductItem> get filteredProducts {
    // Read all reactive deps so GetX rebuilds when any filter changes.
    final _ = _productService.productsVersion.value;
    final sortMode = sort.value;
    final sel = selectedCategory.value;
    final rangeActive = priceFilterActive.value;
    final range = appliedPriceRange.value;
    final size = selectedSize.value;
    final brand = selectedBrand.value;
    final gender = selectedGender.value;

    var list =
        _productService.getAllProducts().where((p) => p.isActive).toList();

    // Category filter
    if (sel != null && sel.isNotEmpty) {
      list = list.where((p) => p.category?.trim() == sel).toList();
    }

    // Price filter
    if (rangeActive) {
      list = list.where((p) {
        final e = _productService.effectivePrice(p);
        return e >= range.start && e <= range.end;
      }).toList();
    }

    // Size filter
    if (size != null) {
      list = list.where((p) => p.size == size).toList();
    }

    // Brand filter
    if (brand != null && brand.isNotEmpty) {
      list = list.where((p) => p.brandName == brand).toList();
    }

    // Gender filter
    if (gender != null && gender.isNotEmpty) {
      list = list.where((p) => (p.gender ?? 'unisex') == gender).toList();
    }

    // Sort
    switch (sortMode) {
      case AllProductsSort.priceLowHigh:
        list.sort((a, b) => _productService
            .effectivePrice(a)
            .compareTo(_productService.effectivePrice(b)));
        break;
      case AllProductsSort.priceHighLow:
        list.sort((a, b) => _productService
            .effectivePrice(b)
            .compareTo(_productService.effectivePrice(a)));
        break;
      case AllProductsSort.nameAZ:
        list.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case AllProductsSort.newest:
        list.sort(ProductService.compareCatalogNewestFirst);
        break;
    }

    return list;
  }

  // ── Available filter labels ───────────────────────────────────────────────────

  List<String> get categoryLabels {
    final _ = _productService.productsVersion.value;
    return _productService.activeCategoryLabels;
  }

  /// Distinct sizes (ml) that appear on at least one active product, sorted asc.
  List<int> get availableSizes {
    final _ = _productService.productsVersion.value;
    final set = <int>{};
    for (final p in _productService.getAllProducts()) {
      if (!p.isActive) continue;
      if (p.size != null) set.add(p.size!);
    }
    return set.toList()..sort();
  }

  /// Distinct brand names that appear on at least one active product, sorted.
  List<String> get availableBrands {
    final _ = _productService.productsVersion.value;
    final set = <String>{};
    for (final p in _productService.getAllProducts()) {
      if (!p.isActive) continue;
      final b = p.brandName?.trim();
      if (b != null && b.isNotEmpty) set.add(b);
    }
    return set.toList()..sort();
  }

  // ── Active filter flag (used for dot indicator on filter icon) ───────────────

  bool get anyFilterActive =>
      priceFilterActive.value ||
      selectedSize.value != null ||
      selectedBrand.value != null ||
      selectedGender.value != null;

  // ── Setters ───────────────────────────────────────────────────────────────────

  void selectCategory(String? category) => selectedCategory.value = category;

  void selectSize(int? size) => selectedSize.value = size;

  void selectBrand(String? brand) => selectedBrand.value = brand;

  void selectGender(String? gender) => selectedGender.value = gender;

  /// Applies slider selection; if it covers full 0–1 lac, price filter is off.
  void applyPriceFilterFromSheet(RangeValues values) {
    appliedPriceRange.value = values;
    final b = kPriceBounds;
    final coversFull =
        (values.start <= b.start + 0.5) && (values.end >= b.end - 0.5);
    priceFilterActive.value = !coversFull;
  }

  void clearPriceFilter() {
    priceFilterActive.value = false;
    appliedPriceRange.value = catalogPriceRange;
  }

  void setSort(AllProductsSort s) => sort.value = s;

  /// Call when opening filter sheet so slider matches catalog bounds.
  void syncAppliedRangeToCatalogIfNeeded() {
    if (!priceFilterActive.value) {
      appliedPriceRange.value = catalogPriceRange;
    }
  }
}
