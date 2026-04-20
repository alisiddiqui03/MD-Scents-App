import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/services/wallet_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../../app/data/models/app_user.dart';
import '../../../../app/widgets/app_branded_loading.dart';
import '../../../../app/widgets/milestone_tracker_widget.dart';

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
                  _buildWalletCard(),
                  Obx(() {
                    final u = AuthService.to.currentUser.value;
                    if (u == null || !u.isVipActive) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 14),
                        _VipProfileHighlightCard(user: u),
                      ],
                    );
                  }),
                  const SizedBox(height: 14),
                  _buildOrderStatsRow(),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MilestoneTrackerWidget(
                      milestoneOrderCount: user.milestoneOrderCount,
                    ),
                  ),
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
                  _buildAccountSection(context),
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
      expandedHeight: 264,
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
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 40,
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
                Obx(() {
                  final u = AuthService.to.currentUser.value;
                  if (u == null || !u.isVipActive) {
                    return const SizedBox.shrink();
                  }
                  final end = u.vipEndDate!;
                  final plan = (u.vipType ?? '').toLowerCase() == 'yearly'
                      ? 'Yearly'
                      : 'Monthly';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent.withValues(alpha: 0.95),
                              const Color(0xFFFFD700).withValues(alpha: 0.95),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'VIP · $plan · ${DateFormat('dd MMM yyyy').format(end)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
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

  Widget _buildWalletCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        WalletService.to.balance.value;
        WalletService.to.pendingRewards.value;
        final bal = WalletService.to.balance.value;
        final pend = WalletService.to.pendingRewards.value;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed(Routes.USER_WALLET),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Wallet',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'PKR ${bal.toStringAsFixed(0)} available'
                            '${pend > 0.009 ? ' · PKR ${pend.toStringAsFixed(0)} pending' : ''} · Tap for history',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textDark.withValues(alpha: 0.55),
                              fontSize: 12,
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
          ),
        );
      }),
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

  Widget _buildAccountSection(BuildContext context) {
    return Obx(() {
      final admin = AuthService.to.currentUser.value?.isAdmin == true;
      return _MenuCard(
        items: [
          _MenuItemTile(
            item: _MenuItem(
              icon: Icons.card_giftcard_outlined,
              label: 'Refer & Earn',
              subtitle: 'Your code, invites & rewards',
              color: AppColors.accent,
              onTap: () => Get.toNamed(Routes.USER_REFER_EARN),
            ),
          ),
          _MenuItemTile(
            item: _MenuItem(
              icon: Icons.workspace_premium_outlined,
              label: 'MD VIP Club',
              subtitle: 'VIP benefits, milestones & high roller bonus',
              color: AppColors.accent,
              onTap: () => Get.toNamed(Routes.USER_VIP_DASHBOARD),
            ),
          ),
          _buildBirthdayTile(context),
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
          _MenuItemTile(
            item: _MenuItem(
              icon: Icons.reviews_outlined,
              label: 'My Reviews',
              subtitle: 'Your photo reviews and rewards',
              color: AppColors.accent,
              onTap: () => Get.toNamed('/user/my-reviews'),
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
          _MenuItemTile(
            item: _MenuItem(
              icon: Icons.delete_outline,
              label: 'Delete account',
              subtitle: 'Remove your profile, wallet, referrals and rewards',
              color: AppColors.danger,
              onTap: () => _showDeleteAccountDialog(context),
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
                  'Effective Date: 11 April 2026\n\n'
                  'MD Scents values your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.\n\n'
                  '1. Information We Collect\n'
                  'Account Information: When you register via Google, email, or phone number, we may collect your name, email address, and contact details.\n'
                  'Transaction Data: To process your orders, we collect your delivery address, billing details, and payment proof (such as screenshots for manual bank transfers). We do not collect or store your credit/debit card details or banking credentials.\n'
                  'App Activity: We may track your wishlist items, order history, and discount-related activity to improve your user experience.\n'
                  'Device Information: We may collect non-personal device data, such as device identifiers (e.g., Firebase Cloud Messaging token) and Advertising IDs, for notifications, ad delivery, and app functionality.\n\n'
                  '2. How We Use Your Information\n'
                  'To process, fulfill, and deliver your orders.\n'
                  'To manage your account and personalize your user experience.\n'
                  'To send order updates, shipping statuses, and promotional notifications.\n'
                  'To provide customer support and respond to inquiries.\n\n'
                  '3. Third-Party Services & Advertising\n'
                  'We use third-party services, such as Google AdMob, to display promotional advertisements within the app. These services may collect non-personal data, such as your IP address and mobile Advertising ID, to provide relevant ads and calculate discount rewards.\n'
                  'We also use Firebase services (provided by Google) for user authentication, push notifications, and app functionality. Firebase may collect device-related information and identifiers to ensure the proper performance of app features and to deliver notifications successfully.\n'
                  'We strictly do not share your personal identifiable information (such as your name, email, or exact order details) with these third-party advertisers.\n\n'
                  '4. Payment Information\n'
                  'We offer Cash on Delivery (COD) and manual Bank Transfer options. For bank transfers, users are required to upload payment proof (such as a receipt screenshot) directly into the app. We do not collect, process, or store sensitive financial information like credit/debit card numbers or banking passwords.\n\n'
                  '5. Data Security\n'
                  'We implement industry-standard security measures to protect your personal data from unauthorized access, alteration, or disclosure. All sensitive information and account authentication data is transmitted securely using encryption.\n\n'
                  '6. Data Retention and Deletion\n'
                  'We retain your personal data only for as long as necessary to provide our services, fulfill your orders, and comply with legal obligations.\n'
                  'You may request the complete deletion of your account and associated personal data at any time. You can delete your account directly within the app\'s profile settings or request deletion by emailing us at the contact address provided below.\n\n'
                  '7. Your Rights\n'
                  'You have the right to access, update, correct, or delete your personal information. You can manage your profile details directly within the MD Scents app or contact our support team for assistance.\n\n'
                  '8. Children\'s Privacy\n'
                  'This application is not intended for children under the age of 13. We do not knowingly collect or solicit personal data from children. If we discover that a child under 13 has provided us with personal information, we will delete it immediately.\n\n'
                  '9. Contact Us\n'
                  'If you have any questions, concerns, or requests regarding this Privacy Policy or your personal data, please contact us at:\n'
                  'Email: umair.1917@gmail.com',
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

  Widget _buildBirthdayTile(BuildContext context) {
    return Obx(() {
      final user = AuthService.to.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      final hasBirthday = user.birthday != null;
      final birthdayStr = hasBirthday
          ? DateFormat('dd MMMM yyyy').format(user.birthday!)
          : 'Not set yet';

      return _MenuItemTile(
        item: _MenuItem(
          icon: Icons.cake_outlined,
          label: 'Birthday Reward',
          subtitle: hasBirthday
              ? 'Birthday: $birthdayStr (Contact support to change)'
              : 'Set your birthday to earn 10 points reward!',
          color: hasBirthday ? Colors.grey : AppColors.primary,
          onTap: hasBirthday
              ? null
              : () {
                  final now = DateTime.now();
                  showDatePicker(
                    context: context,
                    initialDate: DateTime(now.year - 20),
                    firstDate: DateTime(now.year - 100),
                    lastDate: now,
                    helpText: 'SELECT YOUR BIRTHDAY',
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            onSurface: AppColors.textDark,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  ).then((picked) {
                    if (picked != null) {
                      controller.setBirthday(picked);
                    }
                  });
                },
        ),
      );
    });
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

  void _showDeleteAccountDialog(BuildContext context) {
    final user = AuthService.to.firebaseUser.value;
    final hasEmailProvider =
        user?.providerData.any(
          (provider) => provider.providerId == 'password',
        ) ==
        true;
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete account', style: AppTextStyles.titleLarge),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will permanently delete your profile, wallet balance, referral rewards, order history, wishlist, addresses, reviews, and all personalization.',
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                ),
                const SizedBox(height: 14),
                if (hasEmailProvider) ...[
                  Text(
                    'Please confirm your password to continue.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  Text(
                    'Your Google account will be used to confirm deletion.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.5),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (hasEmailProvider &&
                  !(formKey.currentState?.validate() ?? false)) {
                return;
              }
              Navigator.pop(context);

              try {
                await controller.deleteAccount(
                  password: hasEmailProvider
                      ? passwordController.text.trim()
                      : null,
                );
              } catch (error) {
                Get.snackbar(
                  'Unable to delete account',
                  error is Exception ? error.toString() : 'Please try again.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.danger,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(12),
                );
              }
            },
            child: Text(
              'Delete',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
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
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.onTap,
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

class _VipProfileHighlightCard extends StatelessWidget {
  const _VipProfileHighlightCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final end = user.vipEndDate!;
    final plan = (user.vipType ?? '').toLowerCase() == 'yearly'
        ? 'Yearly'
        : 'Monthly';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFF8E1),
              AppColors.accent.withValues(alpha: 0.14),
              AppColors.primary.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC9A227), Color(0xFFFFE082)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MD VIP Member',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$plan plan · until ${DateFormat('dd MMM yyyy').format(end)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.textDark.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Enjoy double points, exclusive products, and member perks.',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                height: 1.35,
                color: AppColors.textDark.withValues(alpha: 0.58),
              ),
            ),
          ],
        ),
      ),
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
