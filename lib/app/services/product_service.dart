import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/product.dart';
import 'firestore_service.dart';
import 'auth_service.dart';
import '../routes/app_pages.dart';

/// Central place to provide product/category/banner data.
/// Now backed by Firestore for products, with static in-memory banners/categories.
class ProductService extends GetxService {
  ProductService();

  static ProductService get to => Get.find<ProductService>();

  final RxList<ProductItem> _allProducts = <ProductItem>[].obs;

  /// Bumps on every Firestore products snapshot (for admin inventory sync).
  final productsVersion = 0.obs;

  /// True until first products snapshot arrives from Firestore.
  final isProductsLoading = true.obs;
  final isDiscountLoading = true.obs;
  final globalDiscountPercent = 0.0.obs;

  /// Products at or below this stock level count as "low stock" (admin alerts).
  final lowStockThreshold = 5.obs;

  /// Offers screen: starting discount % (Firestore `discounts/store_config`).
  final adBoostBasePercent = 5.0.obs;

  /// Offers screen: max discount % after watching ads.
  final adBoostMaxPercent = 20.0.obs;

  /// Extra discount % per completed rewarded ad.
  final adBoostPerWatchPercent = 0.25.obs;

  /// When false, hide rewarded + banner ad UI (config still in Firestore).
  final adsRewardEnabled = true.obs;

  final List<BannerData> _banners = const [
    BannerData(
      title: 'Explore Entire Collection',
      subtitle: 'Luxury Fragrances',
      tag: 'Shop Now',
      assetPath: 'assets/images/banners/banner_explore.jpg',
      routeName: Routes.USER_ALL_PRODUCTS,
    ),
    BannerData(
      title: 'Shop By Brands',
      subtitle: 'Premium Selection',
      tag: 'Explore',
      assetPath: 'assets/images/banners/banner_brands.jpg',
      routeName: Routes.USER_ALL_PRODUCTS,
    ),
    BannerData(
      title: 'Shop By Size',
      subtitle: 'Choose your fit',
      tag: '30ml - 200ml',
      assetPath: 'assets/images/banners/banner_sizes.jpg',
      routeName: Routes.USER_ALL_PRODUCTS,
    ),
    BannerData(
      title: 'Shop By Gender',
      subtitle: 'Find your scent',
      tag: 'Male • Female • Unisex',
      assetPath: 'assets/images/banners/banner_gender.jpg',
      routeName: Routes.USER_ALL_PRODUCTS,
    ),
  ];

  final List<CategoryItem> _categories = const [
    CategoryItem(id: '0', label: 'All', emoji: '✨'),
    CategoryItem(id: '1', label: 'Floral', emoji: '🌸'),
    CategoryItem(id: '2', label: 'Woody', emoji: '🪵'),
    CategoryItem(id: '3', label: 'Oud', emoji: '🕌'),
    CategoryItem(id: '4', label: 'Fresh', emoji: '🌊'),
    CategoryItem(id: '5', label: 'Oriental', emoji: '🌙'),
  ];

  List<BannerData> get banners => _banners;
  List<CategoryItem> get categories => _categories;

  List<ProductItem> get latestProducts {
    final list = _allProducts.where((p) => p.isActive && isVisibleToCurrentUser(p)).toList();
    _sortCatalogNewestFirst(list);
    return list;
  }

  /// Home horizontal strip — admin marks products as featured when saving.
  List<ProductItem> get featuredProducts {
    final list = _allProducts
        .where((p) => p.isActive && p.isFeatured && isVisibleToCurrentUser(p))
        .toList();
    _sortCatalogNewestFirst(list);
    return list;
  }

  /// Recently updated first (e.g. admin restocked), then [isNew], else stable.
  static int compareCatalogNewestFirst(ProductItem a, ProductItem b) {
    final ta = a.updatedAt ?? a.createdAt;
    final tb = b.updatedAt ?? b.createdAt;
    if (ta != null && tb != null) {
      final c = tb.compareTo(ta);
      if (c != 0) return c;
    } else if (ta != null) {
      return -1;
    } else if (tb != null) {
      return 1;
    }
    if (a.isNew != b.isNew) return a.isNew ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  void _sortCatalogNewestFirst(List<ProductItem> list) {
    list.sort(compareCatalogNewestFirst);
  }

  List<ProductItem> getAllProducts() => _allProducts.toList();

  /// Unique non-empty `category` values from active products (Firestore), sorted.
  List<String> get activeCategoryLabels {
    final set = <String>{};
    for (final p in _allProducts) {
      if (!p.isActive) continue;
      if (!isVisibleToCurrentUser(p)) continue;
      final c = p.category?.trim();
      if (c != null && c.isNotEmpty) set.add(c);
    }
    final list = set.toList()..sort();
    return list;
  }

  bool isVisibleToCurrentUser(ProductItem p) {
    if (!p.isVipOnly) return true;
    final u = AuthService.to.currentUser.value;
    return u?.isVipActive == true;
  }

  /// All catalog items (including inactive) with stock at or below [lowStockThreshold].
  int get lowStockProductCount {
    final t = lowStockThreshold.value;
    return _allProducts.where((p) => p.stock <= t).length;
  }

  bool isLowStock(ProductItem p) => p.stock <= lowStockThreshold.value;

  ProductItem? findById(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _listenToProducts();
    _listenToGlobalDiscount();
  }

  void _listenToProducts() {
    // Full collection so admin inventory sees new/inactive products immediately.
    // User-facing lists (latestProducts, etc.) still filter by isActive.
    FirestoreService.productsCollection.snapshots().listen(
        (QuerySnapshot<Map<String, dynamic>> snapshot) {
      final items = snapshot.docs
          .map((doc) => ProductItem.fromMap(doc.id, doc.data()))
          .toList();
      _allProducts.assignAll(items);
      isProductsLoading.value = false;
      productsVersion.value++;
    });
  }

  /// One-shot fetch (pull-to-refresh). Stream keeps syncing afterward.
  Future<void> refreshCatalogFromServer() async {
    try {
      await Future.wait([
        _refreshProductsOnce(),
        _refreshStoreConfigOnce(),
      ]);
    } catch (_) {
      // Real-time listener may still update; user can pull again.
    }
  }

  Future<void> _refreshProductsOnce() async {
    final snapshot = await FirestoreService.productsCollection.get(
      const GetOptions(source: Source.server),
    );
    final items = snapshot.docs
        .map((doc) => ProductItem.fromMap(doc.id, doc.data()))
        .toList();
    _allProducts.assignAll(items);
    isProductsLoading.value = false;
    productsVersion.value++;
  }

  Future<void> _refreshStoreConfigOnce() async {
    final doc = await FirestoreService.discountsCollection
        .doc('store_config')
        .get(const GetOptions(source: Source.server));
    _applyStoreConfig(doc.data());
    isDiscountLoading.value = false;
  }

  void _applyStoreConfig(Map<String, dynamic>? data) {
    final d = data ?? <String, dynamic>{};
    final raw = (d['globalDiscountPercent'] as num?)?.toDouble() ?? 0;
    globalDiscountPercent.value = raw.clamp(0, 90).toDouble();
    final rawLow = (d['lowStockThreshold'] as num?)?.toInt() ?? 5;
    lowStockThreshold.value = rawLow.clamp(1, 999);

    var base = (d['adBoostBasePercent'] as num?)?.toDouble() ?? 5;
    var max = (d['adBoostMaxPercent'] as num?)?.toDouble() ?? 20;
    final perWatch =
        (d['adBoostPerWatchPercent'] as num?)?.toDouble() ?? 0.25;
    final adsOn = d['adsRewardEnabled'] as bool? ?? true;
    base = base.clamp(0, 90);
    max = max.clamp(base, 90);
    adBoostBasePercent.value = base;
    adBoostMaxPercent.value = max;
    adBoostPerWatchPercent.value = perWatch.clamp(0.05, 25);
    adsRewardEnabled.value = adsOn;
  }

  Future<void> upsertProduct(ProductItem product) async {
    final ref = FirestoreService.productsCollection.doc(product.id);
    final exists = (await ref.get()).exists;
    final data = product.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();
    if (!exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> deleteProduct(String id) async {
    await FirestoreService.productsCollection.doc(id).delete();
  }

  void _listenToGlobalDiscount() {
    FirestoreService.discountsCollection
        .doc('store_config')
        .snapshots()
        .listen((doc) {
      _applyStoreConfig(doc.data());
      isDiscountLoading.value = false;
    });
  }

  Future<void> setGlobalDiscountPercent(double value) async {
    final safe = value.clamp(0, 90).toDouble();
    await FirestoreService.discountsCollection.doc('store_config').set({
      'globalDiscountPercent': safe,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setLowStockThreshold(int value) async {
    final safe = value.clamp(1, 999);
    await FirestoreService.discountsCollection.doc('store_config').set({
      'lowStockThreshold': safe,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Admin: rewarded-ad / offers discount behaviour (stored in `store_config`).
  Future<void> setAdBoostConfig({
    required double basePercent,
    required double maxPercent,
    required double perWatchPercent,
    required bool adsEnabled,
  }) async {
    var b = basePercent.clamp(0, 90);
    var m = maxPercent.clamp(0, 90);
    if (m < b) m = b;
    final pw = perWatchPercent.clamp(0.05, 25);
    await FirestoreService.discountsCollection.doc('store_config').set({
      'adBoostBasePercent': b,
      'adBoostMaxPercent': m,
      'adBoostPerWatchPercent': pw,
      'adsRewardEnabled': adsEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Admin convenience for the new fixed discount progression flow.
  /// Keeps historical fields intact while only toggling ads availability.
  Future<void> setAdsRewardEnabled(bool enabled) async {
    await FirestoreService.discountsCollection.doc('store_config').set({
      'adsRewardEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Full per-unit breakdown for invoice / cart UI.
  ProductPriceBreakdown breakdown(ProductItem product) {
    final pd = product.discountPercent.clamp(0, 90).toDouble();
    final gd = globalDiscountPercent.value.clamp(0, 90).toDouble();
    final base = product.price;
    final afterProduct = base * (1 - (pd / 100));
    final effective = afterProduct * (1 - (gd / 100));
    return ProductPriceBreakdown(
      basePrice: base,
      productDiscountPercent: pd,
      globalDiscountPercent: gd,
      unitPriceAfterProductDiscount: afterProduct < 0 ? 0 : afterProduct,
      effectiveUnitPrice: effective < 0 ? 0 : effective,
    );
  }

  double effectivePrice(ProductItem product) =>
      breakdown(product).effectiveUnitPrice;

  /// Label for product cards when price is below list (product + global discount).
  /// Returns null if no meaningful discount.
  String? discountBadgeLabel(ProductItem product) {
    final b = breakdown(product);
    final base = b.basePrice;
    if (base <= 0) return null;
    if (b.effectiveUnitPrice >= base - 0.01) return null;
    final pct =
        (((base - b.effectiveUnitPrice) / base) * 100).round().clamp(1, 99);
    return '$pct% OFF';
  }
}

/// Per-unit price breakdown (product discount then global discount).
class ProductPriceBreakdown {
  const ProductPriceBreakdown({
    required this.basePrice,
    required this.productDiscountPercent,
    required this.globalDiscountPercent,
    required this.unitPriceAfterProductDiscount,
    required this.effectiveUnitPrice,
  });

  final double basePrice;
  final double productDiscountPercent;
  final double globalDiscountPercent;
  final double unitPriceAfterProductDiscount;
  final double effectiveUnitPrice;

  double get savingsPerUnitFromProduct =>
      (basePrice - unitPriceAfterProductDiscount).clamp(0.0, double.infinity);

  double get savingsPerUnitFromGlobal =>
      (unitPriceAfterProductDiscount - effectiveUnitPrice)
          .clamp(0.0, double.infinity);
}

