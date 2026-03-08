import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/product_detail_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_pages.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  static const _description =
      'A luxurious fragrance crafted with the finest ingredients. '
      'This perfume blends floral and woody notes to create a timeless '
      'scent that lingers throughout the day. Perfect for any occasion, '
      'it embodies elegance and sophistication in every drop.';

  @override
  Widget build(BuildContext context) {
    final product = controller.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top image area
          _buildImageSection(product.imageUrl),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(product.name),
                  const SizedBox(height: 12),
                  _buildRatingRow(product.rating),
                  const SizedBox(height: 16),
                  Text('Description',
                      style: AppTextStyles.titleLarge.copyWith(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    _description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.65),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPriceStockRow(product.price, product.oldPrice),
                  const SizedBox(height: 20),
                  _buildQuantityRow(),
                ],
              ),
            ),
          ),

          // Bottom bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Real perfume image
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.water_drop_rounded,
                    color: Colors.white54, size: 100),
              ),
            ),
          ),
          // Gradient overlay at bottom for readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: AppColors.textDark),
                  ),
                ),
              ),
            ),
          ),
          // Cart icon
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => Get.toNamed(Routes.USER_CART),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shopping_bag_outlined,
                        size: 18, color: AppColors.textDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 22),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.favorite_border,
              color: AppColors.danger, size: 20),
        ),
      ],
    );
  }

  Widget _buildRatingRow(double rating) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;
    return Row(
      children: [
        ...List.generate(5, (i) {
          if (i < full) {
            return const Icon(Icons.star_rounded,
                color: AppColors.accent, size: 18);
          } else if (i == full && hasHalf) {
            return const Icon(Icons.star_half_rounded,
                color: AppColors.accent, size: 18);
          }
          return Icon(Icons.star_border_rounded,
              color: AppColors.accent.withValues(alpha: 0.4), size: 18);
        }),
        const SizedBox(width: 8),
        Text(
          '$rating (128 reviews)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceStockRow(double price, double? oldPrice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PKR ${price.toStringAsFixed(0)}',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
                fontSize: 26,
              ),
            ),
            if (oldPrice != null)
              Text(
                'PKR ${oldPrice.toStringAsFixed(0)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.4),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Stock: 20',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityRow() {
    return Row(
      children: [
        Text('Quantity:', style: AppTextStyles.bodyLarge),
        const Spacer(),
        Obx(
          () => Row(
            children: [
              _QtyButton(
                icon: Icons.remove,
                onTap: controller.decrement,
              ),
              Container(
                width: 44,
                alignment: Alignment.center,
                child: Text(
                  '${controller.quantity.value}',
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
                ),
              ),
              _QtyButton(
                icon: Icons.add,
                onTap: controller.increment,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Favourite count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '04\nFavs',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.6),
                fontSize: 11,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: controller.addToCart,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Add to Cart',
                      style: AppTextStyles.buttonText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
    );
  }
}
