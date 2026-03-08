import 'package:get/get.dart';

import '../../../../app/constants/app_constants.dart';

class DiscountController extends GetxController {
  final currentDiscount = AppConstants.minDiscountPercent.obs;

  void setDiscount(double value) {
    if (value < AppConstants.minDiscountPercent) {
      currentDiscount.value = AppConstants.minDiscountPercent;
    } else if (value > AppConstants.maxDiscountPercent) {
      currentDiscount.value = AppConstants.maxDiscountPercent;
    } else {
      currentDiscount.value = value;
    }
  }
}

