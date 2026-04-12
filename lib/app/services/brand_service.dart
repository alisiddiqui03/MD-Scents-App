import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../data/models/brand.dart';
import 'firestore_service.dart';

/// Live-streams the `brands` Firestore collection.
/// Call [addBrand] to create a new brand (case-insensitive duplicate guard).
class BrandService extends GetxService {
  BrandService();

  static BrandService get to => Get.find<BrandService>();

  final brands = <Brand>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToBrands();
  }

  void _listenToBrands() {
    FirestoreService.brandsCollection
        .orderBy('name')
        .snapshots()
        .listen(
          (snap) {
            brands.assignAll(
              snap.docs.map((d) => Brand.fromMap(d.id, d.data())).toList(),
            );
            isLoading.value = false;
          },
          onError: (_) => isLoading.value = false,
        );
  }

  /// Creates a brand if it does not already exist (case-insensitive).
  /// Returns the existing or newly-created [Brand], or `null` on empty input.
  Future<Brand?> addBrand(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    // Case-insensitive duplicate check in memory first (fast path).
    final existing = brands.firstWhereOrNull(
      (b) => b.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (existing != null) return existing;

    final ref = FirestoreService.brandsCollection.doc();
    await ref.set({
      'name': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return Brand(id: ref.id, name: trimmed);
  }
}
