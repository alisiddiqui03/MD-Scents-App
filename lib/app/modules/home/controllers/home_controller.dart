// lib/app/modules/home/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/core/constant/http_constants.dart';
import 'package:flutter_application_1/app/core/services/api_services.dart';
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
      // Raw response se AuthModel parse kar rahe hain
      final response = await ApiService.post(
        ApiEndpoints.login,
        data: {
          "email": emailController.text.trim(),
          "password": passwordController.text,
        },
      );

      // Model mein convert karo
      final AuthModel authModel = AuthModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      // Check karo success hai ya nahi
      if (authModel.status == 200 && authModel.data?.token != null) {
        final String accessToken = authModel.data!.token!.accessToken!;
        final String refreshToken = authModel.data!.token!.refreshToken!;

        // Storage mein save karo
        await StorageService.saveTokens(accessToken, refreshToken);

        // Observable update
        token.value = "Token Loaded & Saved Successfully";

        // Optional: User data bhi save kar lo future ke liye
        if (authModel.data?.userData != null) {
          currentUser.value = authModel.data!.userData;
          print(
            "👤 Logged in as: ${currentUser.value?.firstName} ${currentUser.value?.lastName}",
          );
          print("Role: ${currentUser.value?.userRole}");
        }

        // Success
        Get.snackbar(
          "Welcome! 🎉",
          "Login Successful!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        // Profile screen pe le jao
        Get.offAll(() => const GetProfileView());
      } else {
        throw Exception(authModel.message ?? "Login failed");
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
      print("❌ Login Error: $e");

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
