import 'package:cloud_firestore/cloud_firestore.dart';

/// Saved delivery address under `users/{uid}/addresses/{addressId}`.
class DeliveryAddress {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String postalCode;
  final bool isDefault;
  final DateTime? updatedAt;

  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.postalCode,
    this.isDefault = false,
    this.updatedAt,
  });

  /// Single line for compact display (legacy UI).
  String get cityLine => '$city${postalCode.isNotEmpty ? ', $postalCode' : ''}';

  factory DeliveryAddress.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['updatedAt'];
    DateTime? updated;
    if (ts is Timestamp) updated = ts.toDate();

    return DeliveryAddress(
      id: id,
      label: data['label'] as String? ?? 'Home',
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      street: data['street'] as String? ?? '',
      city: data['city'] as String? ?? '',
      postalCode: data['postalCode'] as String? ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'isDefault': isDefault,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
