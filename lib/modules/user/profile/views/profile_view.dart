import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_pages.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final user = AuthService.to.currentUser.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          slivers: [
            _buildSliverHeader(user.displayName, user.email, user.isAdmin),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildOrderStatsRow(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('My Account'),
                  _buildAccountSection(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Support'),
                  _buildSupportSection(context),
                  const SizedBox(height: 28),
                  _buildSignOutButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverHeader(String? displayName, String? email, bool isAdmin) {
    final initials = (displayName?.isNotEmpty == true
            ? displayName!.trim().split(' ').map((e) => e[0]).take(2).join()
            : 'U')
        .toUpperCase();

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        initials,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Get.snackbar(
                          'Edit Profile',
                          'Profile editing will be available soon.',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          borderRadius: 12,
                          margin: const EdgeInsets.all(12),
                        ),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  displayName ?? 'Guest User',
                  style:
                      AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? AppColors.accent.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAdmin ? '👑  Admin' : '✨  Premium Member',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      title: Text(
        'My Profile',
        style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildOrderStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
            _StatItem(
              value: '12',
              label: 'Orders',
              icon: Icons.receipt_long_outlined,
              onTap: () => Get.toNamed(Routes.USER_ORDERS),
            ),
            _divider(),
            _StatItem(
              value: '5',
              label: 'Wishlist',
              icon: Icons.favorite_border_rounded,
              onTap: () => Get.toNamed(Routes.USER_WISHLIST),
            ),
            _divider(),
            _StatItem(
              value: '3',
              label: 'Reviews',
              icon: Icons.star_border_rounded,
              onTap: () => Get.snackbar('Reviews', 'Your reviews coming soon.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.accent,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 40,
        color: Colors.grey.shade200,
      );

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(fontSize: 15),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _MenuCard(
      items: [
        _MenuItem(
          icon: Icons.shopping_bag_outlined,
          label: 'My Orders',
          subtitle: 'Track, return or buy again',
          badge: '3',
          color: AppColors.primary,
          onTap: () => Get.toNamed(Routes.USER_ORDERS),
        ),
        _MenuItem(
          icon: Icons.favorite_border_rounded,
          label: 'Wishlist',
          subtitle: 'Items you saved for later',
          color: AppColors.danger,
          onTap: () => Get.toNamed(Routes.USER_WISHLIST),
        ),
        _MenuItem(
          icon: Icons.location_on_outlined,
          label: 'Delivery Addresses',
          subtitle: 'Manage your saved addresses',
          color: AppColors.success,
          onTap: () => Get.toNamed(Routes.USER_ADDRESSES),
        ),
        _MenuItem(
          icon: Icons.local_offer_outlined,
          label: 'Coupons & Offers',
          subtitle: 'View available discounts',
          color: AppColors.accent,
          onTap: () => Get.toNamed(Routes.USER_DISCOUNT),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _MenuCard(
      items: [
        _MenuItem(
          icon: Icons.help_outline_rounded,
          label: 'Help & Support',
          subtitle: 'FAQs, chat with us',
          color: AppColors.success,
          onTap: () => _showInfoDialog(
            context,
            title: 'Help & Support',
            content:
                'For support, contact us at:\nsupport@mdscents.pk\n\nOr WhatsApp: +92 300 0000000',
          ),
        ),
        _MenuItem(
          icon: Icons.privacy_tip_outlined,
          label: 'Privacy Policy',
          subtitle: 'How we use your data',
          color: const Color(0xFF6B7280),
          onTap: () => _showInfoDialog(
            context,
            title: 'Privacy Policy',
            content:
                'MD Scents respects your privacy. We only collect data necessary to process your orders and improve your experience. Your data is never sold to third parties.',
          ),
        ),
        _MenuItem(
          icon: Icons.info_outline_rounded,
          label: 'About MD Scents',
          subtitle: 'Version 1.0.0',
          color: AppColors.primary,
          onTap: () => _showInfoDialog(
            context,
            title: 'About MD Scents',
            content:
                'MD Scents — Dynamic Perfumes\nVersion 1.0.0\n\nCrafting luxury fragrances for every occasion. Discover our exclusive collection of Oud, Floral, Woody and Oriental perfumes.',
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context,
      {required String title, required String content}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyles.titleLarge),
        content: Text(content,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () async => await controller.signOut(),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded,
                  color: AppColors.danger, size: 20),
              const SizedBox(width: 10),
              Text(
                'Sign Out',
                style:
                    AppTextStyles.buttonText.copyWith(color: AppColors.danger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 14,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _MenuItemTile(item: item),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    indent: 60,
                    endIndent: 16,
                    color: Colors.grey.shade100,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final String? badge;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });
}

class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, color: item.color, size: 20),
      ),
      title: Text(
        item.label,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        item.subtitle,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      trailing: item.badge != null
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.badge!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            )
          : Icon(Icons.chevron_right,
              color: AppColors.textDark.withValues(alpha: 0.3), size: 20),
      onTap: item.onTap,
    );
  }
}
