import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../data/models/product.dart';
import '../data/models/wishlist_item.dart';
import 'firestore_service.dart';

class WishlistService extends GetxService {
  WishlistService();

  static WishlistService get to => Get.find<WishlistService>();

  Stream<List<WishlistItem>> wishlistStream(String uid) {
    return FirestoreService.usersWishlistRef(uid)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => WishlistItem.fromMap(d.id, d.data()))
            .toList());
  }

  Future<List<WishlistItem>> fetchWishlistOnce(String uid) async {
    final snapshot = await FirestoreService.usersWishlistRef(uid)
        .orderBy('addedAt', descending: true)
        .get(const GetOptions(source: Source.server));
    return snapshot.docs
        .map((d) => WishlistItem.fromMap(d.id, d.data()))
        .toList();
  }

  Stream<int> wishlistCountStream(String uid) {
    return FirestoreService.usersWishlistRef(uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<bool> isWishlistedStream(String uid, String productId) {
    return FirestoreService.usersWishlistRef(uid)
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> addToWishlist(String uid, ProductItem product) async {
    final item = WishlistItem(
      productId: product.id,
      name: product.name,
      price: product.price,
      imageUrl: product.imageUrl,
      rating: product.rating,
      addedAt: DateTime.now(),
    );
    await FirestoreService.usersWishlistRef(uid)
        .doc(product.id)
        .set(item.toMap());
  }

  Future<void> removeFromWishlist(String uid, String productId) async {
    await FirestoreService.usersWishlistRef(uid).doc(productId).delete();
  }

  Future<void> clearWishlist(String uid) async {
    final snapshot = await FirestoreService.usersWishlistRef(uid).get();
    final batch = FirestoreService.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
