import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/modules/rewards/views/rewards_view.dart';
import 'package:get/get.dart';
import '../controllers/get_profile_controller.dart';

class GetProfileView extends GetView<GetProfileController> {
  const GetProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => GetProfileController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Obx(() {
        final controller = Get.find<GetProfileController>();

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
                  onPressed: controller.fetchProfile,
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        final user = controller.profile.value?.data?.user;
        final location = controller.profile.value?.data?.location;
        if (user == null) {
          return const Center(child: Text("No profile data"));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  "${user.firstName?[0] ?? ''}${user.lastName?[0] ?? ''}"
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoCard(
                "Full Name",
                "${user.firstName ?? ''} ${user.lastName ?? ''}".trim(),
              ),
              _buildInfoCard("Email", user.email ?? "N/A"),
              _buildInfoCard("Phone", user.phoneNumber ?? "Not set"),
              _buildInfoCard(
                "Date of Birth",
                user.dateOfBirth != null
                    ? "${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}"
                    : "Not set",
              ),
              _buildInfoCard("Gender", user.gender ?? "Not specified"),
              _buildInfoCard("City", user.city ?? "Not set"),
              _buildInfoCard("Role", user.userRole ?? "N/A"),
              _buildInfoCard("Language", user.languagePreference ?? "en"),
              const SizedBox(height: 20),
              const Text(
                "Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildInfoCard(
                "Latitude",
                location?.latitude?.toStringAsFixed(6) ?? "N/A",
              ),
              _buildInfoCard(
                "Longitude",
                location?.longitude?.toStringAsFixed(6) ?? "N/A",
              ),
              ElevatedButton(
                onPressed: () => Get.to(() => RewardsView()),
                child: Text("rewards View"),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value.isEmpty ? "Not set" : value),
      ),
    );
  }
}
