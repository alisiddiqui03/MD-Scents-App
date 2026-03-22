import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/models/product.dart';
import '../../../../app/services/product_service.dart';
import '../../all_products/controllers/all_products_controller.dart';

class FeaturedProductsController extends GetxController {
  final ProductService _productService = ProductService.to;

  /// `null` = all categories among featured.
  final selectedCategory = Rxn<String>();

  final priceFilterActive = false.obs;
  final appliedPriceRange = AllProductsController.kPriceBounds.obs;
  final sort = AllProductsSort.newest.obs;

  RangeValues get catalogPriceRange => AllProductsController.kPriceBounds;

  List<ProductItem> get _featuredOnly {
    final _ = _productService.productsVersion.value;
    return _productService.featuredProducts;
  }

  bool get hasFeaturedProducts {
    final _ = _productService.productsVersion.value;
    return _featuredOnly.isNotEmpty;
  }

  /// Categories that appear on at least one featured product.
  List<String> get categoryLabels {
    final _ = _productService.productsVersion.value;
    final set = <String>{};
    for (final p in _featuredOnly) {
      final c = p.category?.trim();
      if (c != null && c.isNotEmpty) set.add(c);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<ProductItem> get filteredProducts {
    final _ = _productService.productsVersion.value;
    final sortMode = sort.value;
    final sel = selectedCategory.value;
    final rangeActive = priceFilterActive.value;
    final range = appliedPriceRange.value;

    var list = List<ProductItem>.from(_featuredOnly);

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
        break;
    }

    return list;
  }

  void selectCategory(String? category) {
    selectedCategory.value = category;
  }

  void applyPriceFilterFromSheet(RangeValues values) {
    appliedPriceRange.value = values;
    final b = AllProductsController.kPriceBounds;
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
