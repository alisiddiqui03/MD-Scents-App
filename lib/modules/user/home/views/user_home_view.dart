import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/user_home_controller.dart';
import '../../user_base/controllers/user_base_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/services/auth_service.dart';

class UserHomeView extends StatelessWidget {
  const UserHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Resolve once — safe to use ctrl in all helpers without Obx scope issues
    final ctrl = Get.find<UserHomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(ctrl),
            const SizedBox(height: 20),
            _buildCategories(ctrl),
            const SizedBox(height: 24),
            _buildSectionHeader('Latest Collection', onViewAll: () {
              Get.toNamed(Routes.USER_ALL_PRODUCTS);
            }),
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
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textDark),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
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
              icon: const Icon(Icons.shopping_bag_outlined,
                  color: AppColors.textDark),
              onPressed: () => Get.toNamed(Routes.USER_CART),
            ),
            Positioned(
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
                    '2',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Drawer ──────────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext context) {
    final user = AuthService.to.currentUser.value;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      (user?.displayName?.isNotEmpty == true
                              ? user!.displayName![0]
                              : 'U')
                          .toUpperCase(),
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? 'Guest User',
                    style:
                        AppTextStyles.titleLarge.copyWith(color: Colors.white),
                  ),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'My Orders',
                    badge: '3',
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(Routes.USER_ORDERS);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.favorite_border_rounded,
                    label: 'Wishlist',
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(Routes.USER_WISHLIST);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.local_offer_outlined,
                    label: 'Offers & Discounts',
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(Routes.USER_DISCOUNT);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.location_on_outlined,
                    label: 'Delivery Addresses',
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(Routes.USER_ADDRESSES);
                    },
                  ),
                  const Divider(height: 24, indent: 16, endIndent: 16),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Get.find<UserBaseController>().onTabSelected(3);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.grid_view_rounded,
                    label: 'All Products',
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed(Routes.USER_ALL_PRODUCTS);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      Get.snackbar(
                        'Help & Support',
                        'Contact: support@mdscents.pk',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: AppColors.primary,
                        colorText: Colors.white,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(12),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await AuthService.to.signOut();
                  Get.offAllNamed(Routes.AUTH);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Text('Sign Out',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.danger)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
            itemBuilder: (_, index) => _BannerCard(
              data: ctrl.banners[index],
              index: index,
            ),
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

  // ── Categories ──────────────────────────────────────────────────────────────

  Widget _buildCategories(UserHomeController ctrl) {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ctrl.categories.length,
        itemBuilder: (_, i) {
          final cat = ctrl.categories[i];
          return Obx(
            () {
              final selected = ctrl.selectedCategoryIndex.value == i;
              return GestureDetector(
                onTap: () => ctrl.onCategorySelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.grey.shade200,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Text(cat.emoji,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        cat.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: selected
                              ? Colors.white
                              : AppColors.textDark,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title,
      {required VoidCallback onViewAll}) {
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
                    style: AppTextStyles.titleLarge
                        .copyWith(color: Colors.white, fontSize: 16),
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
                        value: (ctrl.discountPercent.value - 5) / 15,
                        minHeight: 7,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['5%', '10%', '15%', '20%']
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
                  onTap: () => Get.toNamed(Routes.USER_DISCOUNT),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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
    return Column(
      children: [
        _buildSectionHeader('Featured Picks', onViewAll: () {
          Get.snackbar(
            'Featured Picks',
            'Full catalogue coming soon.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
          );
        }),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ctrl.featuredProducts.length,
            itemBuilder: (_, i) =>
                _FeaturedCard(product: ctrl.featuredProducts[i]),
          ),
        ),
      ],
    );
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
          Row(
            children: [
              Expanded(
                child: _OfferBanner(
                  title: 'Free Delivery',
                  subtitle: 'On orders above\nPKR 3,000',
                  icon: Icons.local_shipping_outlined,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OfferBanner(
                  title: 'Gift Wrap',
                  subtitle: 'Free on special\noccasions',
                  icon: Icons.card_giftcard_outlined,
                  color: AppColors.secondary,
                ),
              ),
            ],
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
}

// ── Drawer item ───────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: AppTextStyles.bodyLarge),
      trailing: badge != null
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            )
          : const Icon(Icons.chevron_right,
              color: AppColors.textDark, size: 18),
      onTap: onTap,
    );
  }
}

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
                      horizontal: 10, vertical: 4),
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
                      horizontal: 18, vertical: 9),
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
                        top: Radius.circular(14)),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) =>
                          progress == null
                              ? child
                              : Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                ),
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.water_drop_rounded,
                            color: Colors.grey, size: 32),
                      ),
                    ),
                  ),
                  if (product.isNew)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
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
                          'PKR ${product.price.toStringAsFixed(0)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (product.oldPrice != null)
                        Text(
                          product.oldPrice!.toStringAsFixed(0),
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
                        top: Radius.circular(16)),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) =>
                          progress == null
                              ? child
                              : Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                ),
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.water_drop_rounded,
                            color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                  if (product.isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
                      child: const Icon(Icons.favorite_border,
                          color: AppColors.danger, size: 16),
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
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PKR ${product.price.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.accent, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toString(),
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontSize: 11),
                          ),
                        ],
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
                      Text(title,
                          style: AppTextStyles.bodyLarge
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text(subtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  AppColors.textDark.withValues(alpha: 0.6))),
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
                Text(title,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            AppColors.textDark.withValues(alpha: 0.6),
                        fontSize: 11)),
              ],
            ),
    );
  }
}
