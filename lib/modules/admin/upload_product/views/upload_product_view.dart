import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/upload_product_controller.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/loading_overlay.dart';

class UploadProductView extends GetView<UploadProductController> {
  const UploadProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlay(
        isLoading: controller.isSaving.value || controller.isUploadingImage.value,
        title: controller.isSaving.value
            ? 'Saving product'
            : (controller.isUploadingImage.value ? 'Uploading images' : null),
        subtitle: controller.isSaving.value
            ? 'Writing to your store…'
            : (controller.isUploadingImage.value
                ? 'Secure upload in progress — please wait'
                : null),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              controller.isEditing ? 'Edit Product' : 'Add Product',
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Product details',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                minLines: 2,
                maxLines: 5,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 12, right: 4),
                    child: Text(
                      'Rs',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  prefixIconConstraints:
                      BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock quantity',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.discountController,
                decoration: const InputDecoration(
                  labelText: 'Product discount (%)',
                  prefixIcon: Icon(Icons.percent_rounded),
                  hintText: '0 to 90',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Product images',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Add multiple photos — users can swipe through them in the shop.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              _buildImageUploadSection(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Obx(
                    () => Switch(
                      value: controller.isFeatured.value,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor:
                          AppColors.primary.withValues(alpha: 0.45),
                      onChanged: (v) => controller.isFeatured.value = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Show in Featured'),
                ],
              ),
              Row(
                children: [
                  Obx(
                    () => Switch(
                      value: controller.isActive.value,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor:
                          AppColors.primary.withValues(alpha: 0.45),
                      onChanged: (v) => controller.isActive.value = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Active (visible to users)'),
                ],
              ),
              const SizedBox(height: 24),
              Obx(
                () => _buildSaveButton(),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Obx(() {
      final urls = controller.imageUrls;
      final isUploading = controller.isUploadingImage.value;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 112,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...List.generate(urls.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              urls[i],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                onTap: () => controller.removeImageAt(i),
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.close, size: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  _buildAddTile(isUploading),
                ],
              ),
            ),
            if (urls.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: urls.isEmpty ? null : controller.clearAllImages,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove all'),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildAddTile(bool isUploading) {
    // Spinner lives only in LoadingOverlay — here: calm disabled state
    final enabled = controller.cloudinaryConfigured && !isUploading;
    return Material(
      color: isUploading
          ? AppColors.primary.withValues(alpha: 0.04)
          : AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? controller.pickAndUploadImages : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 100,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUploading
                    ? Icons.hourglass_top_rounded
                    : (controller.cloudinaryConfigured
                        ? Icons.add_photo_alternate_outlined
                        : Icons.cloud_off_outlined),
                color: isUploading
                    ? AppColors.primary.withValues(alpha: 0.45)
                    : AppColors.primary,
                size: 30,
              ),
              const SizedBox(height: 6),
              Text(
                isUploading
                    ? 'Please wait'
                    : (controller.cloudinaryConfigured
                        ? 'Add photos'
                        : 'No Cloudinary'),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11,
                  fontWeight: isUploading ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.textDark.withValues(
                    alpha: isUploading ? 0.45 : 0.75,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isSaving.value
            ? null
            : controller.saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          controller.isSaving.value
              ? 'Saving…'
              : (controller.isEditing ? 'Update product' : 'Save product'),
          style: AppTextStyles.buttonText,
        ),
      ),
    );
  }
}
