import 'package:get/get.dart';

import '../../../../app/data/models/order.dart';
import '../../../../app/services/admin_referrals_service.dart';
import '../../../../app/services/order_service.dart';

class AdminReferralDetailController extends GetxController {
  AdminReferralRow? row;

  final order = Rxn<Order>();
  final isLoading = true.obs;
  final errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is! AdminReferralRow) {
      errorMessage.value = 'Invalid referral data.';
      isLoading.value = false;
      return;
    }
    row = args;
    _load();
  }

  Future<void> reload() async {
    if (row == null) return;
    await _load();
  }

  Future<void> _load() async {
    final r = row;
    if (r == null) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final o = await OrderService.to.fetchOrderForBuyer(
        r.referredUserId,
        r.orderId,
      );
      order.value = o;
      if (o == null) {
        errorMessage.value =
            'Order document not found. It may have been removed.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      order.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
