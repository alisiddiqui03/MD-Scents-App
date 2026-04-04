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

  /// `null` = show all products.
  final selectedCategory = Rxn<String>();

  /// When true, only products whose effective price falls in [appliedPriceRange].
  final priceFilterActive = false.obs;

  /// Used when [priceFilterActive] is true (slider selection).
  final appliedPriceRange = kPriceBounds.obs;

  final sort = AllProductsSort.newest.obs;

  /// Slider min/max (always 0–100,000 PKR).
  RangeValues get catalogPriceRange => kPriceBounds;

  List<ProductItem> get filteredProducts {
    final _ = _productService.productsVersion.value;
    final sortMode = sort.value;
    final sel = selectedCategory.value;
    final rangeActive = priceFilterActive.value;
    final range = appliedPriceRange.value;

    var list =
        _productService.getAllProducts().where((p) => p.isActive).toList();

    if (sel != null && sel.isNotEmpty) {
      list = list.where((p) => p.category?.trim() == sel).toList();
    }

    if (rangeActive) {
      list = list.where((p) {
        final e = _productService.effectivePrice(p);
        return e >= range.start && e <= range.end;
      }).toList();
    }

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

  List<String> get categoryLabels {
    final _ = _productService.productsVersion.value;
    return _productService.activeCategoryLabels;
  }

  void selectCategory(String? category) {
    selectedCategory.value = category;
  }

  /// Applies slider selection; if it covers full 0–1 lac, price filter is off.
  void applyPriceFilterFromSheet(RangeValues values) {
    appliedPriceRange.value = values;
    final b = kPriceBounds;
    final coversFull = (values.start <= b.start + 0.5) &&
        (values.end >= b.end - 0.5);
    priceFilterActive.value = !coversFull;
  }

  void clearPriceFilter() {
    priceFilterActive.value = false;
    appliedPriceRange.value = catalogPriceRange;
  }

  void setSort(AllProductsSort s) {
    sort.value = s;
  }

  /// Call when opening filter sheet so slider matches catalog bounds.
  void syncAppliedRangeToCatalogIfNeeded() {
    if (!priceFilterActive.value) {
      appliedPriceRange.value = catalogPriceRange;
    }
  }

  @override
  void onReady() {
    super.onReady();
    appliedPriceRange.value = catalogPriceRange;
  }
}
