import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/services/admin_referrals_service.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/theme/app_colors.dart';

class AdminReferralsController extends GetxController {
  final dateRange = Rx<DateTimeRange?>(null);

  /// Call inside [Obx] after reading [AdminReferralsService.to.rows] so list updates reactively.
  List<AdminReferralRow> filteredRows() {
    final list = List<AdminReferralRow>.from(AdminReferralsService.to.rows);
    final range = dateRange.value;
    if (range == null) return list;

    final start = DateTime(range.start.year, range.start.month, range.start.day);
    final end = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
    );

    return list.where((r) {
      final d = r.createdAt;
      if (d == null) return false;
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();
  }

  void clearDateFilter() => dateRange.value = null;

  Future<void> pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: dateRange.value ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      dateRange.value = picked;
    }
  }

  void openOrderDetail(AdminReferralRow row) {
    Get.toNamed(Routes.ADMIN_REFERRAL_ORDER_DETAIL, arguments: row);
  }
}
