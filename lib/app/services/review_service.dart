import 'package:get/get.dart';

import '../data/models/review.dart';
import 'firestore_service.dart';

class ReviewService extends GetxService {
  ReviewService();

  static ReviewService get to => Get.find<ReviewService>();

  Stream<List<ReviewItem>> productReviewsStream(String productId) {
    return FirestoreService.productReviewsRef(productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((d) => ReviewItem.fromMap(d.id, d.data())).toList());
  }

  Future<void> upsertReview({
    required String uid,
    required String userName,
    required String productId,
    required double rating,
    required String comment,
  }) async {
    final review = ReviewItem(
      id: uid,
      productId: productId,
      userId: uid,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    final batch = FirestoreService.instance.batch();
    final userDoc = FirestoreService.usersReviewsRef(uid).doc(productId);
    final productDoc = FirestoreService.productReviewsRef(productId).doc(uid);
    batch.set(userDoc, review.toMap());
    batch.set(productDoc, review.toMap());
    await batch.commit();
  }
}
