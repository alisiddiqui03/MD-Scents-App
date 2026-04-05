// lib/app/modules/get_profile/controllers/get_profile_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:md_scents_app/app/theme/app_colors.dart';
import 'package:md_scents_app/app/data/providers/api_repositries.dart';
import 'package:md_scents_app/app/data/models/get_profile_model.dart';

class GetProfileController extends GetxController {
  final ApiRepositories apiRepo = ApiRepositories();

  var isLoading = true.obs;
  var profile = Rxn<GetProfile>(); // ← Model observable
  var errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  // GetProfileController.dart → fetchProfile()

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      errorMessage.value = "";

      // Pura model milega
      final GetProfile profileResponse = await apiRepo.getCustomerProfile();

      // Simple check — status 200 hai to data dikhao
      if (profileResponse.status == 200) {
        profile.value = profileResponse;
        print("✅ Profile Loaded: ${profileResponse.data?.user?.firstName}");
      } else {
        throw Exception(profileResponse.message ?? "Unknown error");
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
      profile.value = null;
      print("❌ Profile Error: $e");
      Get.snackbar(
        'Something went wrong',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
      );
    } finally {
      isLoading(false);
    }
  }
}
