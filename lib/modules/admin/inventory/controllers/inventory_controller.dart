import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/models/product.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/utils/admin_snackbar.dart';

class InventoryController extends GetxController {
  final ProductService _productService = ProductService.to;

  final items = <ProductItem>[].obs;
  final adBasePercent = 5.0.obs;
  final adMaxPercent = 20.0.obs;
  final adPerAdBoost = 1.0.obs;
  final adsEnabled = true.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  /// Set while a product delete is in progress.
  final isDeleting = false.obs;

  late final Worker _productsWorker;

  @override
  void onInit() {
    super.onInit();
    _loadInventory();
    _productsWorker = ever(
      _productService.productsVersion,
      (_) => _loadInventory(),
    );
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _productsWorker.dispose();
    super.onClose();
  }

  void _loadInventory() {
    final all = List<ProductItem>.from(_productService.getAllProducts())
      ..sort(_newestProductFirst);
    items.assignAll(all);
  }

  /// Products visible for current search (name contains, case-insensitive).
  List<ProductItem> get filteredItems {
    final q = searchQuery.value.trim().toLowerCase();
    final list = items.toList();
    if (q.isEmpty) return list;
    return list
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  int get totalItems =>
      items.fold(0, (sum, p) => sum + (p.stock < 0 ? 0 : p.stock));

  Future<void> deleteProduct(ProductItem product) async {
    isDeleting.value = true;
    try {
      await _productService.deleteProduct(product.id);
      items.removeWhere((p) => p.id == product.id);
      AdminSnackbar.success(
        'Product removed',
        '"${product.name}" was deleted from the catalog.',
      );
    } catch (e) {
      AdminSnackbar.error('Could not delete', e.toString());
    } finally {
      isDeleting.value = false;
    }
  }

  void refreshFromService() {
    _loadInventory();
  }
}

/// New uploads use ids like `p-<millisecondsSinceEpoch>` — sort those newest-first.
/// Other ids (legacy) sort by name below.
int _newestProductFirst(ProductItem a, ProductItem b) {
  final ma = _millisFromProductId(a.id);
  final mb = _millisFromProductId(b.id);
  if (ma != null && mb != null) return mb.compareTo(ma);
  if (ma != null) return -1;
  if (mb != null) return 1;
  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
}

int? _millisFromProductId(String id) {
  if (id.startsWith('p-')) {
    return int.tryParse(id.substring(2));
  }
  return null;
}
