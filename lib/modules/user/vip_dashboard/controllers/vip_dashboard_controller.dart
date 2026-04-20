import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/services/auth_service.dart';
import '../../../../app/services/cloudinary_service.dart';
import '../../../../app/services/firestore_service.dart';
import '../../../../app/services/vip_service.dart';
import '../../../../app/theme/app_colors.dart';

class VipDashboardController extends GetxController {
  final selectedPlan = 'monthly'.obs;
  final screenshotUrl = ''.obs;
  final isUploadingScreenshot = false.obs;
  final isSubmittingRequest = false.obs;
  final hasPendingVipRequest = false.obs;

  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _vipRequestSub;

  @override
  void onInit() {
    super.onInit();
    _bindMyVipRequest();
  }

  @override
  void onReady() {
    super.onReady();
    _bindMyVipRequest();
  }

  @override
  void onClose() {
    _vipRequestSub?.cancel();
    super.onClose();
  }

  void _bindMyVipRequest() {
    final uid = AuthService.to.currentUser.value?.uid;
    if (uid == null) return;
    _vipRequestSub?.cancel();
    _vipRequestSub = FirestoreService.vipRequestsCollection
        .doc(uid)
        .snapshots()
        .listen((snap) {
      if (!snap.exists) {
        hasPendingVipRequest.value = false;
        return;
      }
      final st =
          (snap.data()?['status'] as String?)?.trim().toLowerCase() ?? '';
      hasPendingVipRequest.value = st == 'pending';
    });
  }

  void prepareYearlyUpgrade() {
    selectedPlan.value = 'yearly';
    screenshotUrl.value = '';
  }

  Future<void> pickAndUploadScreenshot() async {
    if (isUploadingScreenshot.value) return;
    if (hasPendingVipRequest.value) return;
    isUploadingScreenshot.value = true;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 88,
      );
      if (picked == null) return;
      final file = File(picked.path);
      if (!await file.exists()) {
        throw StateError('Selected file is not available');
      }
      final url = await _cloudinaryService.uploadImage(file);
      screenshotUrl.value = url;
      Get.snackbar(
        'Screenshot uploaded',
        'Payment proof uploaded successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Upload failed',
        e.toString().replaceFirst('StateError: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isUploadingScreenshot.value = false;
    }
  }

  Future<void> submitVipRequest() async {
    if (isSubmittingRequest.value) return;
    if (hasPendingVipRequest.value) {
      Get.snackbar(
        'Request pending',
        'Request already submitted.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.accent,
        colorText: Colors.white,
      );
      return;
    }
    if (screenshotUrl.value.trim().isEmpty) {
      Get.snackbar(
        'Screenshot required',
        'Please upload payment screenshot first.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    isSubmittingRequest.value = true;
    try {
      await VipService.to.submitVipPaymentRequest(
        planType: selectedPlan.value,
        screenshotUrl: screenshotUrl.value,
      );
      Get.snackbar(
        'Success',
        'VIP request submitted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('StateError: ', '');
      Get.snackbar(
        'Could not submit request',
        msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: submitVipRequest,
          child: const Text(
            'Retry',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    } finally {
      isSubmittingRequest.value = false;
    }
  }
}
