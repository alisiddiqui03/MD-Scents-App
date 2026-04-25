import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/upload_product_controller.dart';
import '../../../../app/services/brand_service.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/widgets/loading_overlay.dart';

class UploadProductView extends GetView<UploadProductController> {
  const UploadProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlay(
        isLoading:
            controller.isSaving.value || controller.isUploadingImage.value,
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
            title: Text(controller.isEditing ? 'Edit Product' : 'Add Product'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Section: Product Details ─────────────────────────────
                  Text('Product details', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),

                  // ── Brand dropdown ───────────────────────────────────────
                  _buildBrandSection(),
                  const SizedBox(height: 16),
                  _buildGenderSection(),
                  const SizedBox(height: 20),

                  // ── Perfume name ─────────────────────────────────────────
                  TextField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Perfume name',
                      hintText: 'e.g. Aventus',
                      prefixIcon: Icon(Icons.water_drop_outlined),
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Preview of the generated full display name
                  _buildDisplayNamePreview(),
                  const SizedBox(height: 12),

                  // ── Description ──────────────────────────────────────────
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
                  // ── Actual Size (Manual Input) ───────────────────────────
                  TextField(
                    controller: controller.unitSizeController,
                    decoration: const InputDecoration(
                      labelText: 'Actual Size (e.g. 80ml, 125ml)',
                      hintText: 'What users will see as size',
                      prefixIcon: Icon(Icons.straighten_outlined),
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Size (ml) selector (NOW AS CATEGORY) ────────────────────────
                  _buildSizeSelector(),
                  const SizedBox(height: 20),

                  // ── Price ────────────────────────────────────────────────
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
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Stock ────────────────────────────────────────────────
                  TextField(
                    controller: controller.stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock quantity',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Discount (optional) ──────────────────────────────────
                  TextField(
                    controller: controller.discountController,
                    decoration: const InputDecoration(
                      labelText: 'Product discount (%) — optional',
                      prefixIcon: Icon(Icons.percent_rounded),
                      hintText: 'Leave empty for 0%',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Images ───────────────────────────────────────────────
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

                  // ── Toggles ──────────────────────────────────────────────
                  Row(
                    children: [
                      Obx(
                        () => Switch(
                          value: controller.isFeatured.value,
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withValues(
                            alpha: 0.45,
                          ),
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
                          activeTrackColor: AppColors.primary.withValues(
                            alpha: 0.45,
                          ),
                          onChanged: (v) => controller.isActive.value = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Active (visible to users)'),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(
                        () => Switch(
                          value: controller.isVipOnly.value,
                          activeThumbColor: AppColors.accent,
                          activeTrackColor:
                              AppColors.accent.withValues(alpha: 0.45),
                          onChanged: (v) => controller.isVipOnly.value = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VIP exclusive (hide for non‑VIP)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Save button ───────────────────────────────────────────
                  Obx(() => _buildSaveButton()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Gender section ──────────────────────────────────────────────────────────

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedGender.value,
                isExpanded: true,
                items: controller.genderOptions
                    .map(
                      (g) => DropdownMenuItem(
                        value: g,
                        child: Text(
                          g.capitalizeFirst!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.selectedGender.value = v;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Brand section ────────────────────────────────────────────────────────────

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brand',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textDark.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        // Dropdown: picks from live BrandService list + "Add New Brand"
        Obx(() {
          final brands = BrandService.to.brands;
          final loading = BrandService.to.isLoading.value;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedBrand.value,
                isExpanded: true,
                hint: Text(
                  loading ? 'Loading brands…' : 'Select a brand (optional)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.45),
                    fontSize: 14,
                  ),
                ),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  fontSize: 14,
                ),
                iconEnabledColor: AppColors.textDark,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                menuMaxHeight: 300,
                items: [
                  // Clear / no brand option
                  DropdownMenuItem<String>(
                    value: '__none__',
                    child: Text(
                      'No brand',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.55),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Existing brands from Firestore
                  ...brands.map(
                    (b) => DropdownMenuItem<String>(
                      value: b.name,
                      child: Text(b.name),
                    ),
                  ),
                  // Add new brand option
                  DropdownMenuItem<String>(
                    value: '__add_new__',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add new brand',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (v) {
                  if (v == '__add_new__') {
                    controller.startAddingNewBrand();
                  } else if (v == '__none__') {
                    controller.selectedBrand.value = null;
                    controller.cancelAddingBrand();
                  } else {
                    controller.selectedBrand.value = v;
                    controller.cancelAddingBrand();
                  }
                },
              ),
            ),
          );
        }),

        // Inline "Add new brand" text field (shown only when adding)
        Obx(() {
          if (!controller.isAddingNewBrand.value) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New brand name',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.newBrandController,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Creed',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Save new brand
                      Obx(
                        () => IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: controller.isSavingBrand.value
                              ? null
                              : controller.saveNewBrand,
                          icon: controller.isSavingBrand.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                        ),
                      ),
                      // Cancel
                      IconButton(
                        onPressed: controller.cancelAddingBrand,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Display name preview ─────────────────────────────────────────────────────

  Widget _buildDisplayNamePreview() {
    return Obx(() {
      final brand = controller.selectedBrand.value?.trim() ?? '';
      final perfume = controller.nameController.text.trim();
      if (perfume.isEmpty) return const SizedBox.shrink();
      final full = brand.isNotEmpty ? '$brand $perfume' : perfume;
      return Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 2),
        child: Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 13,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Display name: $full',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Size selector ─────────────────────────────────────────────────────────────

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Internal Size Category',
              style: AppTextStyles.titleLarge.copyWith(fontSize: 15),
            ),
            const SizedBox(width: 6),
            Text(
              '— for organization',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                color: AppColors.textDark.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final sel = controller.selectedSize.value;
          return Wrap(
            spacing: 10,
            runSpacing: 8,
            children: kSizeOptions.map((ml) {
              final selected = sel == ml;
              return GestureDetector(
                onTap: () => controller.selectedSize.value = ml,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.primary : Colors.grey,
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    '${ml}ml',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selected ? Colors.white : AppColors.textDark,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // ── Image upload section ──────────────────────────────────────────────────────

  Widget _buildImageUploadSection() {
    return Obx(() {
      final urls = controller.imageUrls;
      final isUploading = controller.isUploadingImage.value;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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

  // ── Save button ───────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isSaving.value ? null : controller.saveProduct,
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
