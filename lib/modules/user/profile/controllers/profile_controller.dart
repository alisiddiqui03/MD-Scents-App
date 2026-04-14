import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/services/auth_service.dart';
import '../../../../app/services/firestore_service.dart';
import '../../../../app/services/order_service.dart';
import '../../../../app/services/wishlist_service.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/data/models/points_history.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService.to;
  final OrderService _orderService = OrderService.to;

  final isSettingBirthday = false.obs;

  final orderCount = 0.obs;
  final wishlistCount = 0.obs;
  StreamSubscription? _ordersSub;
  StreamSubscription? _wishlistSub;

  @override
  void onInit() {
    super.onInit();
    ever(_authService.currentUser, (_) {
      _listenToUserOrders();
      _listenToWishlist();
    });
    if (_authService.currentUser.value != null) {
      _listenToUserOrders();
      _listenToWishlist();
    }
  }

  Future<void> setBirthday(DateTime date) async {
    final user = _authService.currentUser.value;
    if (user == null) return;
    if (user.birthday != null) return;

    isSettingBirthday.value = true;
    try {
      final userRef = FirestoreService.usersCollection.doc(user.uid);

      await FirestoreService.instance.runTransaction((txn) async {
        final snap = await txn.get(userRef);
        final data = snap.data() ?? {};

        if (data['birthday'] != null) {
          throw 'Birthday already set';
        }

        final currentPoints = (data['points'] as num?)?.toInt() ?? 0;

        txn.update(userRef, {
          'birthday': Timestamp.fromDate(date),
          'birthdayRewardGiven': true,
          'points': currentPoints + 10,
        });

        // Add to history
        final historyRef =
            FirestoreService.usersPointsHistoryRef(user.uid).doc();
        final historyItem = PointHistoryItem(
          id: historyRef.id,
          type: 'birthday',
          points: 10,
          createdAt: DateTime.now(),
        );
        txn.set(historyRef, historyItem.toMap());
      });

      await _authService.refreshProfile();

      Get.snackbar(
        'Birthday Saved! 🎉',
        'Your 10 points birthday reward has been added to your wallet.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isSettingBirthday.value = false;
    }
  }

  void _listenToUserOrders() {
    _ordersSub?.cancel();
    final uid = _authService.currentUser.value?.uid;
    if (uid == null) {
      orderCount.value = 0;
      return;
    }
    _ordersSub = _orderService.userOrdersStream(uid).listen((orders) {
      orderCount.value = orders.length;
    });
  }

  void _listenToWishlist() {
    _wishlistSub?.cancel();
    final uid = _authService.currentUser.value?.uid;
    if (uid == null) {
      wishlistCount.value = 0;
      return;
    }
    _wishlistSub = WishlistService.to.wishlistCountStream(uid).listen((count) {
      wishlistCount.value = count;
    });
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    _wishlistSub?.cancel();
    super.onClose();
  }

  Future<void> signOut() async {
    // Show confirmation dialog before signing out
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: AppTextStyles.titleLarge),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.5),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Sign Out',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _authService.signOut();
    // Clear entire navigation stack and go to auth screen
    Get.offAllNamed(Routes.AUTH);
  }

  Future<void> deleteAccount({String? password}) async {
    await _authService.deleteCurrentUser(password: password);
    Get.offAllNamed(Routes.AUTH);
  }
}
