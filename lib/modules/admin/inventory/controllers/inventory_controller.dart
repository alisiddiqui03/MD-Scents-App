import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../app/data/models/product.dart';
import '../../../../app/services/firestore_service.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/utils/admin_snackbar.dart';

class InventoryController extends GetxController {
  final ProductService _productService = ProductService.to;

  final items = <ProductItem>[].obs;
  final userDiscountRows = <UserDiscountRow>[].obs;
  final isUserDiscountsLoading = true.obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  /// Set while a product delete is in progress.
  final isDeleting = false.obs;

  late final Worker _productsWorker;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSub;

  @override
  void onInit() {
    super.onInit();
    _loadInventory();
    _productsWorker = ever(
      _productService.productsVersion,
      (_) => _loadInventory(),
    );
    _bindUserDiscountMonitor();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    _usersSub?.cancel();
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

  /// Kept for view compatibility (no configurable ad sliders anymore).
  void syncAdConfigFromProductService() {}

  void _bindUserDiscountMonitor() {
    isUserDiscountsLoading.value = true;
    _usersSub?.cancel();
    _usersSub = FirestoreService.usersCollection
        .where('role', isEqualTo: 'user')
        .snapshots()
        .listen((snapshot) {
      final rows = snapshot.docs.map((doc) {
        final d = doc.data();
        final discount = (d['currentDiscountPercent'] as num?)?.toDouble() ?? 0;
        final adsWatched = (d['adsWatchedCount'] as num?)?.toInt() ?? 0;
        final received = d['hasReceivedWelcomeDiscount'] as bool? ?? false;
        final used = d['hasUsedWelcomeDiscount'] as bool? ?? false;
        return UserDiscountRow(
          uid: doc.id,
          name: (d['displayName'] as String?)?.trim().isNotEmpty == true
              ? (d['displayName'] as String).trim()
              : ((d['email'] as String?)?.trim().isNotEmpty == true
                  ? (d['email'] as String).trim()
                  : doc.id),
          currentDiscountPercent: discount.clamp(0, 20).toDouble(),
          adsWatchedCount: adsWatched < 0 ? 0 : adsWatched,
          hasReceivedWelcomeDiscount: received,
          hasUsedWelcomeDiscount: used,
        );
      }).toList()
        ..sort(
          (a, b) => b.currentDiscountPercent.compareTo(a.currentDiscountPercent),
        );
      userDiscountRows.assignAll(rows);
      isUserDiscountsLoading.value = false;
    }, onError: (_) {
      isUserDiscountsLoading.value = false;
    });
  }
}

class UserDiscountRow {
  const UserDiscountRow({
    required this.uid,
    required this.name,
    required this.currentDiscountPercent,
    required this.adsWatchedCount,
    required this.hasReceivedWelcomeDiscount,
    required this.hasUsedWelcomeDiscount,
  });

  final String uid;
  final String name;
  final double currentDiscountPercent;
  final int adsWatchedCount;
  final bool hasReceivedWelcomeDiscount;
  final bool hasUsedWelcomeDiscount;
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
