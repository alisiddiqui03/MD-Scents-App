import 'dart:async';

import 'package:get/get.dart';

import '../../../../app/data/models/review.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/services/review_service.dart';

class MyReviewsController extends GetxController {
  final reviews = <ReviewItem>[].obs;
  final isLoading = true.obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid != null) {
      _sub = ReviewService.to.userReviewsStream(uid).listen((data) {
        reviews.value = data;
        isLoading.value = false;
      });
    } else {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
