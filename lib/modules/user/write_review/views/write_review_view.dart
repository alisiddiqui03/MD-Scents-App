import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/write_review_controller.dart';

class WriteReviewView extends GetView<WriteReviewController> {
  const WriteReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Write Review'), centerTitle: true),
      body: Obx(() {
        if (controller.isSubmitting.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 20),
                Text(
                  controller.isUploading.value
                      ? 'Uploading images securely...'
                      : 'Finalizing review...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wallet_giftcard_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Earn 250 PKR',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add pictures and a short review to instantly get wallet credit.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Rating
              Text('RATE YOUR ORDER', style: _labelStyle()),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => controller.rating.value = index + 1.0,
                    icon: Icon(
                      index < controller.rating.value
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.accent,
                      size: 40,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Photos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ADD PHOTOS (Required)', style: _labelStyle()),
                  Text(
                    '${controller.localImages.length} / 3',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (controller.localImages.length < 3)
                      GestureDetector(
                        onTap: controller.pickImages,
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ...controller.localImages.asMap().entries.map((entry) {
                      final i = entry.key;
                      final path = entry.value;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => controller.removeImage(i),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Comment
              Text('REVIEW (Optional)', style: _labelStyle()),
              const SizedBox(height: 12),
              TextField(
                controller: controller.commentController,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Share details about delivery, packaging, and fragrances (Optional)...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 40),

              // Submit
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: controller.submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Submit Review & Claim Reward',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  TextStyle _labelStyle() {
    return AppTextStyles.bodyMedium.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: AppColors.textDark.withValues(alpha: 0.6),
    );
  }
}
