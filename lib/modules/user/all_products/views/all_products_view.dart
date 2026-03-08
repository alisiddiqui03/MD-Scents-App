import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/controllers/user_home_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_pages.dart';

class AllProductsView extends StatelessWidget {
  const AllProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<UserHomeController>();
    final allProducts = [...ctrl.latestProducts, ...ctrl.featuredProducts];

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
          'ALL PRODUCTS',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textDark),
            onPressed: () => Get.snackbar(
              'Filters',
              'Advanced filters coming soon.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.primary,
              colorText: Colors.white,
              borderRadius: 12,
              margin: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(ctrl),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: allProducts.length,
              itemBuilder: (_, i) => _ProductCard(product: allProducts[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(UserHomeController ctrl) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: ctrl.categories.length,
          itemBuilder: (_, i) {
            final cat = ctrl.categories[i];
            return Obx(() {
              final selected = ctrl.selectedCategoryIndex.value == i;
              return GestureDetector(
                onTap: () => ctrl.onCategorySelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '${cat.emoji} ${cat.label}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: selected ? Colors.white : AppColors.textDark,
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductItem product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.USER_PRODUCT_DETAIL,
        arguments: {'id': product.id},
      ),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Center(
                          child: Icon(Icons.water_drop_outlined,
                              color: AppColors.primary, size: 32),
                        ),
                      ),
                    ),
                  ),
                  if (product.isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NEW',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => Get.snackbar(
                        'Wishlist',
                        '${product.name} added to wishlist.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: AppColors.primary,
                        colorText: Colors.white,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border_rounded,
                            color: AppColors.danger, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.accent, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 11,
                          color: AppColors.textDark.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.oldPrice != null)
                            Text(
                              'PKR ${product.oldPrice!.toStringAsFixed(0)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 10,
                                color: AppColors.textDark
                                    .withValues(alpha: 0.4),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            'PKR ${product.price.toStringAsFixed(0)}',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
