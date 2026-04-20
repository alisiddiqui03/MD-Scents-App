import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/services/auth_service.dart';
import '../../../../app/services/firestore_service.dart';
import '../../../../app/services/vip_service.dart';
import '../../../../app/utils/admin_snackbar.dart';

enum VipUserListFilter { all, vipOnly, nonVip, pendingRequests }

class AdminVipManagementController extends GetxController {
  final vipRequests = <VipRequestRow>[].obs;
  final users = <VipUserRow>[].obs;
  final isRequestsLoading = true.obs;
  final isUsersLoading = true.obs;
  final actionUid = RxnString();

  final userListFilter = VipUserListFilter.all.obs;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _requestsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usersSub;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    _bindRequests();
    _bindUsers();
  }

  @override
  void onClose() {
    _requestsSub?.cancel();
    _usersSub?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void _bindRequests() {
    isRequestsLoading.value = true;
    _requestsSub?.cancel();
    _requestsSub = FirestoreService.vipRequestsCollection
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((d) {
        final data = d.data();
        return VipRequestRow(
          id: d.id,
          uid: (data['uid'] as String?)?.trim() ?? d.id,
          userName: (data['userName'] as String?)?.trim(),
          userEmail: (data['userEmail'] as String?)?.trim(),
          planType: ((data['planType'] as String?)?.trim().toLowerCase() ??
              'monthly'),
          screenshotUrl: (data['screenshotUrl'] as String?)?.trim() ?? '',
          createdAt: data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
        );
      }).toList()
        ..sort((a, b) {
          final ad = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bd = b.createdAt?.millisecondsSinceEpoch ?? 0;
          return bd.compareTo(ad);
        });
      vipRequests.assignAll(list);
      isRequestsLoading.value = false;
    }, onError: (_) {
      isRequestsLoading.value = false;
    });
  }

  void _bindUsers() {
    isUsersLoading.value = true;
    _usersSub?.cancel();
    _usersSub = FirestoreService.usersCollection
        .where('role', isEqualTo: 'user')
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return VipUserRow(
          uid: doc.id,
          name: (data['displayName'] as String?)?.trim(),
          email: (data['email'] as String?)?.trim(),
          isVip: data['isVip'] as bool? ?? false,
          vipType: (data['vipType'] as String?)?.trim().toLowerCase(),
          vipEndDate: (data['vipEndDate'] is Timestamp)
              ? (data['vipEndDate'] as Timestamp).toDate()
              : null,
        );
      }).toList()
        ..sort((a, b) => a.displayName.toLowerCase().compareTo(
              b.displayName.toLowerCase(),
            ));
      users.assignAll(list);
      isUsersLoading.value = false;
    }, onError: (_) {
      isUsersLoading.value = false;
    });
  }

  bool isVipActive(VipUserRow u) {
    if (!u.isVip || u.vipEndDate == null) return false;
    return u.vipEndDate!.isAfter(DateTime.now());
  }

  List<VipUserRow> filteredUsers() {
    final q = searchQuery.value.trim().toLowerCase();
    Iterable<VipUserRow> list = users;

    switch (userListFilter.value) {
      case VipUserListFilter.vipOnly:
        list = list.where(isVipActive);
        break;
      case VipUserListFilter.nonVip:
        list = list.where((u) => !isVipActive(u));
        break;
      case VipUserListFilter.pendingRequests:
        final pendingUids = vipRequests.map((r) => r.uid).toSet();
        list = list.where((u) => pendingUids.contains(u.uid));
        break;
      case VipUserListFilter.all:
        break;
    }

    if (q.isNotEmpty) {
      list = list.where((u) {
        final name = u.displayName.toLowerCase();
        return name.contains(q) || u.uid.toLowerCase().contains(q);
      });
    }

    return list.toList();
  }

  Future<void> activateVip({
    required String uid,
    required String vipType,
    required String userLabel,
  }) async {
    if (actionUid.value != null) return;
    actionUid.value = uid;
    try {
      await VipService.to.activateVipForUser(uid: uid, vipType: vipType);
      AdminSnackbar.success(
        'VIP activated',
        '$userLabel is now ${vipType == 'yearly' ? 'Yearly' : 'Monthly'} VIP.',
      );
    } catch (e) {
      AdminSnackbar.error(
        'Activation failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      actionUid.value = null;
    }
  }

  Future<void> approveRequest(VipRequestRow req) async {
    if (actionUid.value != null) return;
    actionUid.value = req.uid;
    try {
      await VipService.to.activateVipForUser(uid: req.uid, vipType: req.planType);
      await FirestoreService.vipRequestsCollection.doc(req.id).set({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': AuthService.to.currentUser.value?.uid,
      }, SetOptions(merge: true));
      AdminSnackbar.success(
        'Request approved',
        '${req.displayName} activated as ${req.planType == 'yearly' ? 'Yearly' : 'Monthly'} VIP.',
      );
    } catch (e) {
      AdminSnackbar.error(
        'Approval failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      actionUid.value = null;
    }
  }

  Future<void> deactivateVip({
    required String uid,
    required String userLabel,
  }) async {
    if (actionUid.value != null) return;
    actionUid.value = uid;
    try {
      await VipService.to.deactivateVipForUser(uid: uid);
      AdminSnackbar.success(
        'VIP deactivated',
        '$userLabel membership was turned off.',
      );
    } catch (e) {
      AdminSnackbar.error(
        'Deactivation failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      actionUid.value = null;
    }
  }
}

class VipRequestRow {
  const VipRequestRow({
    required this.id,
    required this.uid,
    required this.userName,
    required this.userEmail,
    required this.planType,
    required this.screenshotUrl,
    required this.createdAt,
  });

  final String id;
  final String uid;
  final String? userName;
  final String? userEmail;
  final String planType;
  final String screenshotUrl;
  final DateTime? createdAt;

  String get displayName {
    if (userName != null && userName!.trim().isNotEmpty) return userName!.trim();
    if (userEmail != null && userEmail!.trim().isNotEmpty) return userEmail!.trim();
    return uid;
  }
}

class VipUserRow {
  const VipUserRow({
    required this.uid,
    required this.name,
    required this.email,
    required this.isVip,
    required this.vipType,
    required this.vipEndDate,
  });

  final String uid;
  final String? name;
  final String? email;
  final bool isVip;
  final String? vipType;
  final DateTime? vipEndDate;

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    if (email != null && email!.trim().isNotEmpty) return email!.trim();
    return uid;
  }
}

