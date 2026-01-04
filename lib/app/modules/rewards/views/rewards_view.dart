import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/rewards_controller.dart';

class RewardsView extends GetView<RewardsController> {
  const RewardsView({super.key});
  @override
  Widget build(BuildContext context) {
      Get.lazyPut(() => RewardsController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('RewardsView'),
        centerTitle: true,
      ),
      body: Obx(() {
        final controller = Get.find<RewardsController>(); 

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                ElevatedButton(
                  onPressed: controller.fetchrewards,
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Active Rewards: ${controller.profile.value?.data?.activeRewards ?? 0}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                'Used/Expired Rewards: ${controller.profile.value?.data?.usedExpiredRewards ?? 0}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        );
        
  })
  );

  }
  
}
