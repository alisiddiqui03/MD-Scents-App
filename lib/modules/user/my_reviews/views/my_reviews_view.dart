import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/utils/order_action_time.dart';
import '../controllers/my_reviews_controller.dart';

class MyReviewsView extends GetView<MyReviewsController> {
  const MyReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Picture Reviews'),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.reviews_outlined,
                    size: 64,
                    color: AppColors.textDark.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload a picture review from an order to earn PKR 250!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final review = controller.reviews[index];
              final displayId = '#MD-${review.orderId.length > 6 ? review.orderId.substring(0, 6).toUpperCase() : review.orderId.toUpperCase()}';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.03),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ORDER $displayId',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatOrderActionTime(review.createdAt),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textDark.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          if (review.rewardGiven)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stars_rounded, color: AppColors.success, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PKR 250 Earned',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.success,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Rating & Text
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: AppColors.accent,
                                size: 18,
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            review.comment,
                            style: AppTextStyles.bodyMedium.copyWith(
                              height: 1.4,
                              color: AppColors.textDark.withValues(alpha: 0.8),
                            ),
                          ),

                          // Pictures
                          if (review.images.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 70,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: review.images.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (_, i) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: review.images[i],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20, height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.error_outline),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
