import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.put() NOT needed here if you use bindings or lazyPut
    // But safe to use once
    //Get.lazyPut(() => HomeController());
    print("Saved Token:\n${controller.token.value}");

    return Scaffold(
      appBar: AppBar(title: const Text("My Slushie Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            children: [
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              if (controller.errorMessage.value.isNotEmpty)
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.login,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "Saved Token:\n${controller.token.value}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Test Credentials:\nmehfooz.connect_test2@gmail.com\nPassword: Karachi12345",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
