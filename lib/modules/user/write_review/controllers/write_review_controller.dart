import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/data/models/order.dart';
import '../../../../app/services/cloudinary_service.dart';
import '../../../../app/services/review_service.dart';

class WriteReviewController extends GetxController {
  late final Order order;

  final commentController = TextEditingController();
  final rating = 5.0.obs;

  final localImages = <String>[].obs;
  final isUploading = false.obs;
  final isSubmitting = false.obs;

  final _picker = ImagePicker();
  final _cloudinary = CloudinaryService();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Order) {
      order = args;
    } else {
      Get.back();
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  Future<void> pickImages() async {
    try {
      final xFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (xFiles.isNotEmpty) {
        if (localImages.length + xFiles.length > 3) {
          Get.snackbar('Limit Reached', 'You can upload up to 3 images.');
          return;
        }
        for (var f in xFiles) {
          localImages.add(f.path);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
    }
  }

  void removeImage(int index) {
    localImages.removeAt(index);
  }

  Future<void> submitReview() async {
    if (localImages.isEmpty) {
      Get.snackbar(
        'Required',
        'Please add at least 1 picture of your order.',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    // Text comment is optional

    isSubmitting.value = true;
    isUploading.value = true;

    try {
      final uploadedUrls = <String>[];
      for (final path in localImages) {
        final url = await _cloudinary.uploadImage(File(path));
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      isUploading.value = false;

      // Submit
      await ReviewService.to.submitOrderReview(
        orderId: order.id,
        rating: rating.value,
        comment: commentController.text.trim(),
        images: uploadedUrls,
      );

      Get.back(); // close write screen
      Get.snackbar(
        'Reward Earned! 💸',
        'Your review is submitted and 250 PKR has been added to your wallet.',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isSubmitting.value = false;
      isUploading.value = false;
    }
  }
}
