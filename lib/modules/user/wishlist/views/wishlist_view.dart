import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/models/wishlist_item.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/wishlist_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'WISHLIST',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        centerTitle: true,
        actions: [
          Obx(() => controller.items.isEmpty
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: () async {
                    await controller.clearAll();
                    Get.snackbar(
                      'Wishlist Cleared',
                      'All items removed from wishlist.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColors.primary,
                      colorText: Colors.white,
                      borderRadius: 12,
                      margin: const EdgeInsets.all(12),
                    );
                  },
                  child: Text(
                    'Clear',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
        ],
      ),
      body: Obx(() {
        Future<void> onRefresh() => controller.refreshWishlist();

        if (controller.isLoading.value) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.45,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }
        if (controller.items.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  child: Center(
                    child: Text(
                      'No wishlist items yet.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: controller.items
                .map((item) => _WishlistCard(item: item))
                .toList(),
          ),
        );
      }),
    );
  }
}

class _WishlistCard extends GetView<WishlistController> {
  final WishlistItem item;

  const _WishlistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.network(
              item.imageUrl,
              width: 100,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 110,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.water_drop_outlined,
                    color: AppColors.primary),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'MD Scents',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PKR ${item.price.toStringAsFixed(0)}',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.addToCart(item);
                              Get.snackbar(
                                'Added to Cart',
                                '${item.name} added to your cart.',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: AppColors.success,
                                colorText: Colors.white,
                                borderRadius: 12,
                                margin: const EdgeInsets.all(12),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              await controller.remove(item.productId);
                              Get.snackbar(
                                'Removed',
                                '${item.name} removed from wishlist.',
                                snackPosition: SnackPosition.TOP,
                                backgroundColor: AppColors.primary,
                                colorText: Colors.white,
                                borderRadius: 12,
                                margin: const EdgeInsets.all(12),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.favorite_rounded,
                                  color: AppColors.danger, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
