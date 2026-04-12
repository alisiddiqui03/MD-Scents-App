import 'dart:async';

import 'package:get/get.dart';

import '../../../../app/data/models/review.dart';
import '../../../../app/services/review_service.dart';

class AdminReviewsController extends GetxController {
  final reviews = <ReviewItem>[].obs;
  final isLoading = true.obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = ReviewService.to.adminAllReviewsStream().listen((data) {
      reviews.value = data;
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
