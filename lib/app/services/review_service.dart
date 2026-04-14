import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:get/get.dart';

import '../data/models/review.dart';
import '../data/models/order.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import '../data/models/points_history.dart';

class ReviewService extends GetxService {
  ReviewService();

  static ReviewService get to => Get.find<ReviewService>();

  /// Reward points for submitting a picture review.
  static const int kReviewRewardPoints = 50;

  /// Fetches all reviews for a specific user (for "My Reviews" section).
  Stream<List<ReviewItem>> userReviewsStream(String uid) {
    return FirestoreService.usersReviewsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => ReviewItem.fromMap(d.id, d.data()))
            .toList());
  }

  /// Fetches all user reviews globally for the Admin dashboard.
  /// Sorting is done locally to avoid requiring strict Firestore CollectionGroup index.
  Stream<List<ReviewItem>> adminAllReviewsStream() {
    return FirestoreService.reviewsCollectionGroup
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((d) => ReviewItem.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Securely submits a review under a strict transaction.
  /// Anti-fraud:
  /// 1. Verifies order exists and belongs to user.
  /// 2. Verifies order status == delivered.
  /// 3. Verifies order.reviewSubmitted == false.
  /// 4. Verifies images list is not empty.
  /// 5. Automatically grants PKR 250 to user's wallet.
  Future<void> submitOrderReview({
    required String orderId,
    required double rating,
    required String comment,
    required List<String> images,
  }) async {
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) throw Exception('User not logged in.');

    if (images.isEmpty) {
      throw Exception('At least 1 picture is required to submit a review.');
    }

    final db = FirestoreService.instance;
    final orderRef = FirestoreService.usersOrdersRef(uid).doc(orderId);
    final userRef = FirestoreService.usersCollection.doc(uid);
    final reviewRef = FirestoreService.usersReviewsRef(uid).doc(orderId);

    await db.runTransaction((tx) async {
      final orderSnap = await tx.get(orderRef);
      if (!orderSnap.exists) {
        throw Exception('Order not found.');
      }

      final orderData = orderSnap.data()!;
      final order = Order.fromMap(orderSnap.id, orderData);

      if (order.status != OrderStatus.delivered) {
        throw Exception('Order must be delivered before you can write a review.');
      }

      if (order.reviewSubmitted) {
        throw Exception('A review has already been submitted for this order.');
      }

      final userSnap = await tx.get(userRef);
      final userData = userSnap.exists ? userSnap.data()! : <String, dynamic>{};
      final userName =
          userData['displayName'] as String? ?? order.customerName;

      final currentPoints = (userData['points'] as num?)?.toInt() ?? 0;

      // ── 1. Create the ReviewItem ──────────────────────────────────────────
      final review = ReviewItem(
        id: orderId,
        orderId: orderId,
        userId: uid,
        userName: userName,
        rating: rating,
        comment: comment.trim(),
        images: images,
        rewardGiven: true,
        createdAt: DateTime.now(),
      );

      tx.set(reviewRef, review.toMap());

      // ── 2. Update User Points ─────────────────────────────────────────────
      tx.update(userRef, {'points': currentPoints + kReviewRewardPoints});

      // ── 3. Add to Points History ─────────────────────────────────────────
      final historyRef = FirestoreService.usersPointsHistoryRef(uid).doc();
      final historyItem = PointHistoryItem(
        id: historyRef.id,
        type: 'review',
        points: kReviewRewardPoints,
        createdAt: DateTime.now(),
        referenceId: orderId,
      );
      tx.set(historyRef, historyItem.toMap());

      // ── 4. Update Order ───────────────────────────────────────────────────
      tx.update(orderRef, {'reviewSubmitted': true});
    });
  }
}
