import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a perfume brand stored in `brands/{brandId}`.
class Brand {
  final String id;
  final String name;
  final DateTime? createdAt;

  const Brand({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory Brand.fromMap(String id, Map<String, dynamic> data) {
    return Brand(
      id: id,
      name: data['name'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
