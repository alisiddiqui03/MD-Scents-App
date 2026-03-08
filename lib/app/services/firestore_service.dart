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

  static CollectionReference<Map<String, dynamic>> get discountsCollection =>
      instance.collection('discounts');
}

