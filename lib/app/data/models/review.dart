import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewItem {
  final String id;
  final String orderId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final List<String> images;
  final bool rewardGiven;
  final DateTime createdAt;

  const ReviewItem({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.images,
    required this.rewardGiven,
    required this.createdAt,
  });

  factory ReviewItem.fromMap(String id, Map<String, dynamic> data) {
    var rawImages = data['images'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }

    return ReviewItem(
      id: id,
      orderId: data['orderId'] as String? ?? id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'User',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      comment: data['comment'] as String? ?? '',
      images: parsedImages,
      rewardGiven: data['rewardGiven'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'images': images,
      'rewardGiven': rewardGiven,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
