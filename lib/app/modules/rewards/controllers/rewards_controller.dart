import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/data/models/rewards_model.dart';
import 'package:flutter_application_1/app/data/providers/api_repositries.dart';
import 'package:get/get.dart';

class RewardsController extends GetxController {
  final ApiRepositories apiRepo = ApiRepositories();

  var isLoading = true.obs;
  var profile = Rxn<Reward>(); // ← Model observable
  var errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchrewards();
  }

  Future<void> fetchrewards() async {
    try {
      isLoading(true);
      errorMessage.value = "";

      // Pura model milega
      final Reward rewardresponse = await apiRepo.getrewards();

      // Simple check — status 200 hai to data dikhao
      if (rewardresponse.status == 200) {
        profile.value = rewardresponse;
        print("✅ Reward Loaded: ${rewardresponse.data?.activeRewards}");
        print("✅ Reward Loaded: ${rewardresponse.data?.usedExpiredRewards}");
      } else {
        throw Exception(rewardresponse.message ?? "Unknown error");
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
      profile.value = null;
      print("❌ Reward Error: $e");
      Get.snackbar("Error", errorMessage.value, backgroundColor: Colors.red);
    } finally {
      isLoading(false);
    }
  }
}
