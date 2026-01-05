// lib/app/modules/home/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/core/services/storage_services.dart';
import 'package:flutter_application_1/app/data/providers/api_repositries.dart';
import 'package:flutter_application_1/app/data/models/auth_model.dart'; // ← Yeh import
import 'package:flutter_application_1/app/modules/get_profile/views/get_profile_view.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ApiRepositories apiRepo = ApiRepositories();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var token = "No Token".obs;
  var errorMessage = "".obs;

  // Optional: Agar user data bhi save karna chahte ho (jaise name, role)
  var currentUser = Rxn<UserData>();

  @override
  void onInit() {
    super.onInit();
    loadToken();
  }

  void loadToken() {
    final savedToken = StorageService.token;
    token.value = savedToken != null && savedToken.isNotEmpty
        ? "Token Loaded (Hidden for security)"
        : "No Token Found";
  }

 Future<void> login() async {
  if (emailController.text.trim().isEmpty ||
      passwordController.text.isEmpty) {
    errorMessage.value = "Please enter email and password";
    Get.snackbar("Error", errorMessage.value, backgroundColor: Colors.red);
    return;
  }

  isLoading(true);
  errorMessage.value = "";

  try {
    // ✅ Repository se login call
    final AuthModel authModel = await apiRepo.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (authModel.status == 200 && authModel.data?.token != null) {
      final accessToken = authModel.data!.token!.accessToken!;
      final refreshToken = authModel.data!.token!.refreshToken!;

      await StorageService.saveTokens(accessToken, refreshToken);

      token.value = "Token Loaded & Saved Successfully";

      if (authModel.data?.userData != null) {
        currentUser.value = authModel.data!.userData;
      }

      Get.snackbar(
        "Welcome! 🎉",
        "Login Successful!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAll(() => const GetProfileView());
    } else {
      throw Exception(authModel.message ?? "Login failed");
    }
  } catch (e) {
    errorMessage.value = e.toString().replaceFirst("Exception: ", "");

    Get.snackbar(
      "Login Failed",
      errorMessage.value,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading(false);
  }
}

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
