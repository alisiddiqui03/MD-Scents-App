import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/services/product_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/widgets/app_branded_loading.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final user = AuthService.to.currentUser.value;
        if (user == null) {
          return const AppBrandedLoading();
        }

        return CustomScrollView(
          slivers: [
            _buildSliverHeader(user.displayName, user.email, user.isAdmin),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildOrderStatsRow(),
                  if (user.isAdmin) ...[
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const _AdminLowStockBanner(),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionTitle('Store'),
                    _buildAdminStoreSection(),
                  ],
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
    final initials =
        (displayName?.isNotEmpty == true
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
                const SizedBox(height: 12),
                Text(
                  displayName ?? 'Guest User',
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  email ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '👑  Admin',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      title: const SizedBox.shrink(),
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
        child: Obx(() {
          final orderCount = controller.orderCount.value;
          final wishCount = controller.wishlistCount.value;
          return Row(
            children: [
              _StatItem(
                value: '$orderCount',
                label: 'Orders',
                icon: Icons.receipt_long_outlined,
                onTap: () => Get.toNamed(Routes.USER_ORDERS),
              ),
              _divider(),
              _StatItem(
                value: '$wishCount',
                label: 'Wishlist',
                icon: Icons.favorite_border_rounded,
                onTap: () => Get.toNamed(Routes.USER_WISHLIST),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAdminStoreSection() {
    return _MenuCard(
      items: [
        _MenuItemTile(
          item: _MenuItem(
            icon: Icons.dashboard_outlined,
            label: 'Admin dashboard',
            subtitle: 'Sales, charts & quick stats',
            color: AppColors.primary,
            onTap: () => Get.toNamed(Routes.ADMIN_BASE, arguments: {'tab': 0}),
          ),
        ),
        _MenuItemTile(
          item: _MenuItem(
            icon: Icons.tune_rounded,
            label: 'Store settings',
            subtitle: 'Global discount & low stock threshold',
            color: AppColors.secondary,
            onTap: () => Get.toNamed(Routes.ADMIN_BASE, arguments: {'tab': 3}),
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: Colors.grey.shade200);

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
    return Obx(() {
      final admin = AuthService.to.currentUser.value?.isAdmin == true;
      return _MenuCard(
        items: [
          Obx(
            () => _MenuItemTile(
              item: _MenuItem(
                icon: Icons.shopping_bag_outlined,
                label: 'My Orders',
                subtitle: 'Track, return or buy again',
                badge: controller.orderCount.value > 0
                    ? '${controller.orderCount.value}'
                    : null,
                color: AppColors.primary,
                onTap: () => Get.toNamed(Routes.USER_ORDERS),
              ),
            ),
          ),
          if (admin)
            _MenuItemTile(
              item: _MenuItem(
                icon: Icons.campaign_outlined,
                label: 'Ads & user discounts',
                subtitle: 'Ad flow and user discount monitor',
                color: AppColors.secondary,
                onTap: () => Get.toNamed(Routes.ADMIN_ADS_DISCOUNT),
              ),
            ),
          _MenuItemTile(
            item: _MenuItem(
              icon: Icons.favorite_border_rounded,
              label: 'Wishlist',
              subtitle: 'Items you saved for later',
              color: AppColors.danger,
              onTap: () => Get.toNamed(Routes.USER_WISHLIST),
            ),
          ),
          _MenuItemTile(
            item: _MenuItem(
              icon: Icons.location_on_outlined,
              label: 'Delivery Addresses',
              subtitle: 'Manage your saved addresses',
              color: AppColors.success,
              onTap: () => Get.toNamed(Routes.USER_ADDRESSES),
            ),
          ),
          _MenuItemTile(
            item: _MenuItem(
              icon: Icons.local_offer_outlined,
              label: 'Coupons & Offers',
              subtitle: 'View available discounts',
              color: AppColors.accent,
              onTap: () => Get.toNamed(Routes.USER_DISCOUNT),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSupportSection(BuildContext context) {
    return _MenuCard(
      items: [
        _MenuItemTile(
          item: _MenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            subtitle: 'FAQs, chat with us',
            color: AppColors.success,
            onTap: () => _showInfoDialog(
              context,
              title: '❔ Help & Support (FAQs)',
              content:
                  'Orders & Payments\n\n'
                  'What payment methods do you accept?\n'
                  'We offer Cash on Delivery (COD) for all orders up to PKR 10,000. For orders exceeding PKR 10,000, we require a Bank Transfer. Bank Transfer is also available for orders of any value.\n\n'
                  'How do I pay via Bank Transfer?\n'
                  'At checkout, select "Bank Transfer." You will be provided with our account details. Once you have transferred the amount, simply upload a screenshot of your payment receipt directly in the app to verify your order.\n\n'
                  'How much is delivery?\n'
                  'Delivery is as per TCS standard charges across Pakistan.\n\n'
                  'Discounts & Rewards\n\n'
                  'How does the "Boost Discount" feature work?\n'
                  'All new users automatically get a 5% discount! You can increase this discount up to 20% by tapping the "Boost" button and watching short video ads. Each fully watched ad adds +0.25% to your total discount.\n\n'
                  'When does my discount reset?\n'
                  'Once you successfully place an order using your accumulated discount, your discount tier will reset back to the base level of 5% for your next purchase.\n\n'
                  'General Support\n\n'
                  'How can I contact customer service?\n'
                  'You can reach out to us on our official Instagram/Facebook or message us at our official WhatsApp.\n\n'
                  'What is Glowella?\n'
                  'Glowella is our sister brand specializing in curated skincare routines. You can explore Glowella right from your profile menu!',
            ),
          ),
        ),
        _MenuItemTile(
          item: _MenuItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            subtitle: 'How we use your data',
            color: const Color(0xFF6B7280),
            onTap: () => _showInfoDialog(
              context,
              title: '🛡️ Privacy Policy',
              content:
                  'Effective Date: 23rd March 2026\n\n'
                  'MD Scents values your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.\n\n'
                  '1. Information We Collect\n'
                  'Account Information: When you register via Google, Email, or Phone Number (OTP), we collect your name, email address, and phone number.\n'
                  'Transaction Data: To process your orders, we collect your delivery address, billing details, and payment receipts (for Bank Transfers). We do not store your credit card or bank login details.\n'
                  'App Activity: We track your wishlist items, order history, and discount tier progress to provide a personalized experience.\n\n'
                  '2. How We Use Your Information\n'
                  '• To process and deliver your perfume orders.\n'
                  '• To manage your account, including tracking your "Boost Discount" progress.\n'
                  '• To send you order updates, tracking information, and customer support responses.\n\n'
                  '3. Third-Party Services & Advertising\n'
                  'To power our "Boost Discount" feature, MD Scents uses third-party advertising services (such as Google AdMob). These services may collect non-personal device data (like your device ID or IP address) to serve relevant video advertisements. We do not share your personal identity, order history, or contact information with these advertisers.\n\n'
                  '4. Data Security\n'
                  'We implement industry-standard security measures to protect your account and personal information from unauthorized access. Your authentication data (like passwords and OTPs) is strictly encrypted.\n\n'
                  '5. Your Rights\n'
                  'You have the right to access, update, or delete your personal information at any time. You can manage your details directly from the "My Profile" section of the app or request account deletion by contacting our support team.',
            ),
          ),
        ),
        _MenuItemTile(
          item: _MenuItem(
            icon: Icons.info_outline_rounded,
            label: 'About MD Scents',
            subtitle: 'Version 1.0.0',
            color: AppColors.primary,
            onTap: () => _showInfoDialog(
              context,
              title: 'ℹ️ About MD Scents',
              content:
                  'Welcome to MD Scents – Your Signature Fragrance Awaits.\n\n'
                  'At MD Scents, we believe that a great fragrance is more than just a scent; it is an extension of your personality, your mood, and your memory. We are dedicated to bringing you a curated collection of premium, long-lasting perfumes—ranging from delicate florals and rich woody notes to luxurious ouds.\n\n'
                  'Our mission is to make luxury accessible. That is why we built a unique, interactive shopping experience where you can actively earn discounts just by engaging with our app.\n\n'
                  'As a proud sister brand to Glowella (our premium skincare line), we are committed to helping you look, feel, and smell your absolute best. Thank you for choosing MD Scents to be a part of your daily routine.',
            ),
          ),
        ),
        _MenuItemTile(
          item: _MenuItem(
            icon: Icons.share_outlined,
            label: 'Connect with us',
            subtitle: 'Instagram & Facebook',
            color: AppColors.secondary,
            onTap: () => _showSocialLinksSheet(context),
          ),
        ),
        _MenuItemTile(
          item: _MenuItem(
            icon: Icons.local_fire_department_outlined,
            label: 'Discover Glowella',
            subtitle: 'Explore our Glowvella beauty app',
            color: AppColors.accent,
            onTap: () => _showGlowvellaSheet(context),
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyles.titleLarge),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showSocialLinksSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: false,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Stay connected',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Follow MD Scents on your favourite platforms.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                _SocialLinkTile(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  handle: '@m.d.scents',
                  color: const Color(0xFFE1306C),
                  url:
                      'https://www.instagram.com/m.d.scents?igsh=cHkzZXd5eDhxeGE3',
                ),
                _SocialLinkTile(
                  icon: Icons.facebook_outlined,
                  label: 'Facebook',
                  handle: '/mistydesirescents',
                  color: const Color(0xFF1877F2),
                  url: 'https://www.facebook.com/mistydesirescents',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGlowvellaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: false,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Glowvella – Beauty & Self Care',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover our sister app Glowvella for beauty, skin and self‑care routines.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.75),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            'Coming soon',
                            'Glowvella Play Store link will be added here.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: AppColors.primary,
                            colorText: Colors.white,
                            borderRadius: 12,
                            margin: const EdgeInsets.all(12),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text('Play Store'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.snackbar(
                            'Coming soon',
                            'Glowvella social media links will be added here.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: AppColors.accent,
                            colorText: Colors.white,
                            borderRadius: 12,
                            margin: const EdgeInsets.all(12),
                          );
                        },
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Social media'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          side: BorderSide(
                            color: AppColors.accent.withValues(alpha: 0.7),
                          ),
                          foregroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
      },
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
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Sign Out',
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.danger,
                ),
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
  final List<Widget> items;

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
            final child = entry.value;
            return Column(
              children: [
                child,
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

/// Admin-only: live low stock count from [ProductService], opens Inventory tab.
class _AdminLowStockBanner extends StatelessWidget {
  const _AdminLowStockBanner();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      ProductService.to.productsVersion.value;
      final th = ProductService.to.lowStockThreshold.value;
      final count = ProductService.to.lowStockProductCount;
      final hasIssue = count > 0;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.ADMIN_BASE, arguments: {'tab': 1}),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: hasIssue
                  ? AppColors.danger.withValues(alpha: 0.09)
                  : AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasIssue
                    ? AppColors.danger.withValues(alpha: 0.35)
                    : AppColors.success.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasIssue
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline_rounded,
                  color: hasIssue ? AppColors.danger : AppColors.success,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasIssue
                            ? 'Low stock: $count product(s)'
                            : 'Stock levels OK',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Alert when stock ≤ $th units • Tap for inventory',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.55),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textDark.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          : Icon(
              Icons.chevron_right,
              color: AppColors.textDark.withValues(alpha: 0.3),
              size: 20,
            ),
      onTap: item.onTap,
    );
  }
}

class _SocialLinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String handle;
  final Color color;
  final String url;

  const _SocialLinkTile({
    required this.icon,
    required this.label,
    required this.handle,
    required this.color,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        handle,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark.withValues(alpha: 0.6),
        ),
      ),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Unable to open',
            'Please try again later.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
          );
        }
      },
    );
  }
}
