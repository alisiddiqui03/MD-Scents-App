import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final double rating;
  final DateTime addedAt;

  const WishlistItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.addedAt,
  });

  factory WishlistItem.fromMap(String productId, Map<String, dynamic> data) {
    return WishlistItem(
      productId: productId,
      name: data['name'] as String? ?? 'Unnamed',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'rating': rating,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}
