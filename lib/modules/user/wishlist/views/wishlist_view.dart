import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
class WishlistView extends StatelessWidget {
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
          TextButton(
            onPressed: () => Get.snackbar(
              'Wishlist Cleared',
              'All items removed from wishlist.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.primary,
              colorText: Colors.white,
              borderRadius: 12,
              margin: const EdgeInsets.all(12),
            ),
            child: Text(
              'Clear',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _wishlistItems
            .map((item) => _WishlistCard(item: item))
            .toList(),
      ),
    );
  }
}

class _WishlistItem {
  final String name;
  final String brand;
  final String price;
  final String imageUrl;
  final double rating;

  const _WishlistItem({
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.rating,
  });
}

const _wishlistItems = [
  _WishlistItem(
    name: 'Oud Al Layl',
    brand: 'MD Scents',
    price: 'PKR 4,500',
    imageUrl: 'https://picsum.photos/seed/perfume1/400/400',
    rating: 4.8,
  ),
  _WishlistItem(
    name: 'Rose Elixir',
    brand: 'MD Scents',
    price: 'PKR 3,200',
    imageUrl: 'https://picsum.photos/seed/perfume2/400/400',
    rating: 4.5,
  ),
  _WishlistItem(
    name: 'Midnight Musk',
    brand: 'MD Scents',
    price: 'PKR 2,800',
    imageUrl: 'https://picsum.photos/seed/perfume3/400/400',
    rating: 4.6,
  ),
  _WishlistItem(
    name: 'Amber Noir',
    brand: 'MD Scents',
    price: 'PKR 5,100',
    imageUrl: 'https://picsum.photos/seed/perfume7/400/400',
    rating: 4.9,
  ),
  _WishlistItem(
    name: 'Cedar Wood',
    brand: 'MD Scents',
    price: 'PKR 3,600',
    imageUrl: 'https://picsum.photos/seed/perfume4/400/400',
    rating: 4.4,
  ),
];

class _WishlistCard extends StatelessWidget {
  final _WishlistItem item;

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
          // Image
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
          // Details
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
                    item.brand,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.accent, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        item.rating.toString(),
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.price,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.snackbar(
                              'Added to Cart',
                              '${item.name} added to your cart.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: AppColors.success,
                              colorText: Colors.white,
                              borderRadius: 12,
                              margin: const EdgeInsets.all(12),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Get.snackbar(
                              'Removed',
                              '${item.name} removed from wishlist.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: AppColors.primary,
                              colorText: Colors.white,
                              borderRadius: 12,
                              margin: const EdgeInsets.all(12),
                            ),
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
