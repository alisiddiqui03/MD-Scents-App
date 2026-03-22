import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../data/models/delivery_address.dart';
import 'firestore_service.dart';

class AddressService extends GetxService {
  AddressService();

  static AddressService get to => Get.find<AddressService>();

  /// Live list (sorted: default first, then newest).
  Stream<List<DeliveryAddress>> addressesStream(String uid) {
    return FirestoreService.usersAddressesRef(uid).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => DeliveryAddress.fromMap(d.id, d.data()))
          .toList();
      _sortAddresses(list);
      return list;
    });
  }

  static void _sortAddresses(List<DeliveryAddress> list) {
    list.sort((a, b) {
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      final ta = a.updatedAt ?? DateTime(1970);
      final tb = b.updatedAt ?? DateTime(1970);
      return tb.compareTo(ta);
    });
  }

  Future<List<DeliveryAddress>> fetchAddressesOnce(String uid) async {
    final snap = await FirestoreService.usersAddressesRef(uid).get(
      const GetOptions(source: Source.server),
    );
    final list = snap.docs
        .map((d) => DeliveryAddress.fromMap(d.id, d.data()))
        .toList();
    _sortAddresses(list);
    return list;
  }

  Future<String> addAddress({
    required String uid,
    required String label,
    required String fullName,
    required String phone,
    required String street,
    required String city,
    required String postalCode,
    bool setAsDefault = false,
  }) async {
    final col = FirestoreService.usersAddressesRef(uid);
    final isFirst = (await col.limit(1).get()).docs.isEmpty;
    final doc = col.doc();

    await doc.set({
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'isDefault': isFirst || setAsDefault,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!isFirst && setAsDefault) {
      await _setOnlyDefault(uid, doc.id);
    }
    return doc.id;
  }

  Future<void> updateAddress({
    required String uid,
    required DeliveryAddress existing,
    required String label,
    required String fullName,
    required String phone,
    required String street,
    required String city,
    required String postalCode,
    bool setAsDefault = false,
  }) async {
    final ref = FirestoreService.usersAddressesRef(uid).doc(existing.id);
    await ref.set(
      {
        'label': label,
        'fullName': fullName,
        'phone': phone,
        'street': street,
        'city': city,
        'postalCode': postalCode,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    if (setAsDefault) {
      await _setOnlyDefault(uid, existing.id);
    } else if (existing.isDefault) {
      // User removed default from this address — pick another one.
      final col = FirestoreService.usersAddressesRef(uid);
      final snap = await col.get();
      final other = snap.docs
          .map((d) => d.id)
          .firstWhere((id) => id != existing.id, orElse: () => '');
      if (other.isNotEmpty) {
        await _setOnlyDefault(uid, other);
      }
    }
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    final ref = FirestoreService.usersAddressesRef(uid).doc(addressId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final wasDefault = (doc.data()?['isDefault'] as bool?) ?? false;

    await ref.delete();

    if (wasDefault) {
      final remaining =
          await FirestoreService.usersAddressesRef(uid).limit(1).get();
      if (remaining.docs.isNotEmpty) {
        await _setOnlyDefault(uid, remaining.docs.first.id);
      }
    }
  }

  Future<void> setDefaultAddress(String uid, String addressId) async {
    await _setOnlyDefault(uid, addressId);
  }

  /// Exactly one address has isDefault == true.
  Future<void> _setOnlyDefault(String uid, String addressId) async {
    final col = FirestoreService.usersAddressesRef(uid);
    final snap = await col.get();
    final batch = FirestoreService.instance.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {
        'isDefault': d.id == addressId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
