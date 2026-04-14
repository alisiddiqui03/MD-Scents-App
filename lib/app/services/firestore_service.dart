import 'package:cloud_firestore/cloud_firestore.dart';

/// Thin wrapper around [FirebaseFirestore] for future expansion.
class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore instance = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get usersCollection =>
      instance.collection('users');

  static CollectionReference<Map<String, dynamic>> get productsCollection =>
      instance.collection('products');

  static CollectionReference<Map<String, dynamic>> get ordersCollection =>
      instance.collection('orders');

  /// User-specific orders: users/{userId}/orders
  static CollectionReference<Map<String, dynamic>> usersOrdersRef(String uid) =>
      usersCollection.doc(uid).collection('orders');

  /// User-specific wishlist: users/{userId}/wishlist
  static CollectionReference<Map<String, dynamic>> usersWishlistRef(String uid) =>
      usersCollection.doc(uid).collection('wishlist');

  /// User delivery addresses: users/{userId}/addresses
  static CollectionReference<Map<String, dynamic>> usersAddressesRef(String uid) =>
      usersCollection.doc(uid).collection('addresses');

  /// User-specific reviews: users/{userId}/reviews
  static CollectionReference<Map<String, dynamic>> usersReviewsRef(String uid) =>
      usersCollection.doc(uid).collection('reviews');

  /// User points history: users/{userId}/points_history
  static CollectionReference<Map<String, dynamic>> usersPointsHistoryRef(
          String uid) =>
      usersCollection.doc(uid).collection('points_history');

  /// Product-specific reviews: products/{productId}/reviews
  static CollectionReference<Map<String, dynamic>> productReviewsRef(
          String productId) =>
      productsCollection.doc(productId).collection('reviews');

  /// All orders across users (for admin)
  static Query<Map<String, dynamic>> get ordersCollectionGroup =>
      instance.collectionGroup('orders');

  /// All reviews across users (for admin)
  static Query<Map<String, dynamic>> get reviewsCollectionGroup =>
      instance.collectionGroup('reviews');

  static CollectionReference<Map<String, dynamic>> get discountsCollection =>
      instance.collection('discounts');

  /// Global map: referralCodes/{code} → { uid }
  static CollectionReference<Map<String, dynamic>> get referralCodesCollection =>
      instance.collection('referralCodes');

  /// Perfume brand directory: brands/{brandId} → { name, createdAt }
  static CollectionReference<Map<String, dynamic>> get brandsCollection =>
      instance.collection('brands');
}

