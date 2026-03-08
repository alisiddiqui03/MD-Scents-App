import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_settings_controller.dart';
import '../../../../app/theme/app_text_styles.dart';

class AdminSettingsView extends GetView<AdminSettingsController> {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Placeholder Settings Screen',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Future work: role management, app-wide discounts, inventory thresholds, and notification preferences.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

