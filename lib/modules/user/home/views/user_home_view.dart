import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_home_controller.dart';
import '../../user_base/controllers/user_base_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/data/models/product.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/services/brand_service.dart';
import '../../../../app/widgets/discount_badge.dart';
import '../../../../app/widgets/vip_exclusive_corner_badge.dart';

class UserHomeView extends StatelessWidget {
  const UserHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolve once — safe to use ctrl in all helpers without Obx scope issues
    final ctrl = Get.find<UserHomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ProductService.to.refreshCatalogFromServer(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(ctrl),
              const SizedBox(height: 20),
              _buildBrandsSection(),
              const SizedBox(height: 20),
              _buildSectionHeader(
                'Latest Collection',
                onViewAll: () {
                  Get.toNamed(Routes.USER_ALL_PRODUCTS);
                },
              ),
              const SizedBox(height: 12),
              _buildLatestProductGrid(ctrl),
              const SizedBox(height: 24),
              _buildBoostDiscountBar(ctrl),
              const SizedBox(height: 24),
              _buildFeaturedSection(ctrl),
              const SizedBox(height: 24),
              _buildSpecialOffersSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const SizedBox.shrink(),
      title: Text(
        'MD SCENTS',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.textDark,
              ),
              onPressed: () => Get.find<UserBaseController>().onTabSelected(1),
            ),
            Obx(() {
              final count = Get.find<CartController>().totalQuantity;
              if (count == 0) return const SizedBox.shrink();
              return Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Hero banner ─────────────────────────────────────────────────────────────

  Widget _buildHeroBanner(UserHomeController ctrl) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: ctrl.banners.length,
            onPageChanged: ctrl.onBannerChanged,
            itemBuilder: (_, index) =>
                _BannerCard(data: ctrl.banners[index], index: index),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  ctrl.banners.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: ctrl.currentBannerIndex.value == i ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: ctrl.currentBannerIndex.value == i
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {required VoidCallback onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.titleLarge),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View all',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Latest products grid ────────────────────────────────────────────────────

  Widget _buildLatestProductGrid(UserHomeController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: ctrl.latestProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (_, i) => _ProductCard(product: ctrl.latestProducts[i]),
      ),
    );
  }

  // ── Boost discount bar ──────────────────────────────────────────────────────

  Widget _buildBoostDiscountBar(UserHomeController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1F2A44), Color(0xFF8B5CF6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Boost Discount',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Watch ads to unlock up to 20% off',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Obx(
                      () => LinearProgressIndicator(
                        value: (ctrl.discountPercent.value / 20).clamp(
                          0.0,
                          1.0,
                        ),
                        minHeight: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['0%', '5%', '10%', '20%']
                        .map(
                          (t) => Text(
                            t,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Obx(
                  () => Text(
                    '${ctrl.discountPercent.value.toStringAsFixed(0)}%',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.accent,
                      fontSize: 36,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.find<UserBaseController>().onTabSelected(2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Boost',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Featured (horizontal scroll) ────────────────────────────────────────────

  Widget _buildFeaturedSection(UserHomeController ctrl) {
    return Obx(() {
      ProductService.to.productsVersion.value;
      final list = ctrl.featuredProducts;
      return Column(
        children: [
          _buildSectionHeader(
            'Featured Picks',
            onViewAll: () {
              Get.toNamed(Routes.USER_FEATURED_PRODUCTS);
            },
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'No featured products',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) => _FeaturedCard(product: list[i]),
              ),
            ),
        ],
      );
    });
  }

  // ── Special offers banner ───────────────────────────────────────────────────

  Widget _buildSpecialOffersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Special Offers', style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          _OfferBanner(
            title: 'Gift wrap (optional)',
            subtitle:
                'Available on request when you contact us about your order.',
            icon: Icons.card_giftcard_outlined,
            color: AppColors.secondary,
            wide: true,
          ),
          const SizedBox(height: 12),
          _OfferBanner(
            title: '🎉  Refer & Earn',
            subtitle:
                'Invite friends and get PKR 500 credit on their first order',
            icon: Icons.people_outline_rounded,
            color: AppColors.accent,
            wide: true,
          ),
        ],
      ),
    );
  }

  // ── Brands horizontal scroll ────────────────────────────────────────────────

  Widget _buildBrandsSection() {
    return Obx(() {
      final brands = BrandService.to.brands;
      if (brands.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Shop by Brand',
            onViewAll: () => Get.toNamed(Routes.USER_ALL_PRODUCTS),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: brands.length,
              itemBuilder: (_, i) {
                final brand = brands[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(
                      Routes.USER_ALL_PRODUCTS,
                      arguments: {'brand': brand.name},
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        brand.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
} // end UserHomeView

// ── Banner card ───────────────────────────────────────────────────────────────

class _BannerCard extends StatelessWidget {
  final BannerData data;
  final int index;

  const _BannerCard({required this.data, required this.index});

  static const _gradients = [
    [Color(0xFF1F2A44), Color(0xFF8B5CF6)],
    [Color(0xFF0F172A), Color(0xFF1F2A44)],
    [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[index % _gradients.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 50,
            bottom: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Right side perfume image
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 160,
            child: ClipRect(
              child: Image.network(
                'https://picsum.photos/seed/perfume1/300/300',
                fit: BoxFit.cover,
                color: Colors.white.withValues(alpha: 0.18),
                colorBlendMode: BlendMode.modulate,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 80,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.tag,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.title,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Text(
                  data.subtitle,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Shop Now',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product card (grid) ───────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final ProductItem product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final effectivePrice = ProductService.to.effectivePrice(product);
    final hasDiscount = effectivePrice < product.price;
    final discountLabel = ProductService.to.discountBadgeLabel(product);
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.USER_PRODUCT_DETAIL,
        arguments: {'id': product.id},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.water_drop_rounded,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'NEW',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (discountLabel != null) ...[
                          if (product.isNew) const SizedBox(height: 4),
                          DiscountBadge(text: discountLabel),
                        ],
                      ],
                    ),
                  ),
                  if (product.isVipOnly)
                    const Positioned(
                      bottom: 6,
                      right: 6,
                      child: VipExclusiveCornerBadge(),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'PKR ${effectivePrice.toStringAsFixed(0)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (hasDiscount || product.oldPrice != null)
                        Text(
                          (product.oldPrice ?? product.price).toStringAsFixed(
                            0,
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey,
                            fontSize: 9,
                            decoration: TextDecoration.lineThrough,
                          ),
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

// ── Featured card (horizontal scroll) ────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final ProductItem product;

  const _FeaturedCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final effectivePrice = ProductService.to.effectivePrice(product);
    final discountLabel = ProductService.to.discountBadgeLabel(product);
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.USER_PRODUCT_DETAIL,
        arguments: {'id': product.id},
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.water_drop_rounded,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'NEW',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (discountLabel != null) ...[
                          if (product.isNew) const SizedBox(height: 4),
                          DiscountBadge(text: discountLabel),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: AppColors.danger,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (product.unitSize != null && product.unitSize!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${product.unitSize}${product.unitSize!.toLowerCase().contains('ml') ? '' : 'ml'}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'PKR ${effectivePrice.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
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

// ── Offer banner ──────────────────────────────────────────────────────────────

class _OfferBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool wide;

  const _OfferBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: wide
          ? Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
    );
  }
}
