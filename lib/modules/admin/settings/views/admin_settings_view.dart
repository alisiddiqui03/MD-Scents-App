import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/admin_settings_controller.dart';
import '../../admin_base/controllers/admin_base_controller.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/routes/app_pages.dart';

/// Admin profile + store controls — text tuned for light theme (dark on white).
class AdminSettingsView extends GetView<AdminSettingsController> {
  const AdminSettingsView({super.key});

  static const _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      listTileTheme: ListTileThemeData(
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark.withValues(alpha: 0.58),
          fontSize: 12.5,
          height: 1.35,
        ),
        iconColor: AppColors.primary,
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Admin profile',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textDark,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            Obx(
              () => IconButton(
                tooltip: 'Sign out',
                onPressed: controller.isSigningOut.value
                    ? null
                    : controller.signOut,
                icon: controller.isSigningOut.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.logout_rounded),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileHeaderCard(),
                const SizedBox(height: 20),
                _SectionLabel('Quick navigation'),
                const SizedBox(height: 10),
                _QuickNavCard(),
                const SizedBox(height: 22),
                // _SectionLabel('Referrals'),
                const SizedBox(height: 10),
                //const _ReferralOrdersHubCard(),
                _SectionLabel('Store & catalog'),
                const SizedBox(height: 10),
                _Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.percent_rounded,
                          color: AppColors.accent.withValues(alpha: 0.95),
                        ),
                        title: const Text('Global discount (%)'),
                        subtitle: Text(
                          'Store-wide sale (0–90%). Applied at checkout with product discounts.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.55),
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 72,
                              child: TextField(
                                controller: controller.discountFieldController,
                                textAlign: TextAlign.center,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  suffixText: '%',
                                  suffixStyle: TextStyle(
                                    color: AppColors.textDark.withValues(
                                      alpha: 0.5,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                ),
                                onSubmitted: (_) =>
                                    controller.applyDiscountFromField(),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Obx(
                              () => IconButton.filledTonal(
                                tooltip: 'Apply discount',
                                onPressed: controller.isSaving.value
                                    ? null
                                    : controller.applyDiscountFromField,
                                icon: controller.isSaving.value
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.check_rounded, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.danger.withValues(alpha: 0.85),
                        ),
                        title: const Text('Low stock alert (units)'),
                        subtitle: Text(
                          'Products with stock at or below this number show as low stock (dashboard & inventory).',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.55),
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 72,
                              child: TextField(
                                controller: controller.lowStockFieldController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                ),
                                onSubmitted: (_) =>
                                    controller.applyLowStockFromField(),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Obx(
                              () => IconButton.filledTonal(
                                tooltip: 'Apply threshold',
                                onPressed: controller.isSavingLowStock.value
                                    ? null
                                    : controller.applyLowStockFromField,
                                icon: controller.isSavingLowStock.value
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.check_rounded, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _SectionLabel('About'),
                const SizedBox(height: 10),
                _Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.textDark.withValues(alpha: 0.55),
                    ),
                    title: const Text('App version'),
                    subtitle: Text(
                      'MD Scents admin • build $_appVersion',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => OutlinedButton.icon(
                    onPressed: controller.isSigningOut.value
                        ? null
                        : controller.signOut,
                    icon: controller.isSigningOut.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.danger,
                            ),
                          )
                        : const Icon(Icons.logout_rounded, size: 20),
                    label: Text(
                      controller.isSigningOut.value
                          ? 'Signing out…'
                          : 'Sign out',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textDark.withValues(alpha: 0.45),
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = AuthService.to;
      final email =
          auth.firebaseUser.value?.email ??
          auth.currentUser.value?.email ??
          '—';
      final name =
          auth.currentUser.value?.displayName ??
          auth.firebaseUser.value?.displayName ??
          'Administrator';
      final initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : 'A';

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Administrator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _QuickNavCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = Get.find<AdminBaseController>();

    return _Card(
      child: Column(
        children: [
          _QuickTile(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            subtitle: 'Sales & charts',
            onTap: () => base.currentIndex.value = 0,
          ),
          const Divider(height: 1),
          _QuickTile(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            subtitle: 'Products & stock',
            onTap: () => base.currentIndex.value = 1,
          ),
          const Divider(height: 1),
          _QuickTile(
            icon: Icons.receipt_long_outlined,
            label: 'Orders',
            subtitle: 'Payments & status',
            onTap: () => base.currentIndex.value = 2,
          ),
          const Divider(height: 1),
          _QuickTile(
            icon: Icons.reviews_outlined,
            label: 'All Reviews',
            subtitle: 'User picture reviews & rewards',
            onTap: () => Get.toNamed('/admin/all-reviews'),
          ),
          const Divider(height: 1),
          _QuickTile(
            icon: Icons.workspace_premium_outlined,
            label: 'VIP Requests & Activation',
            subtitle: 'Payment proofs, user VIP data, activate plans',
            onTap: () => Get.toNamed(Routes.ADMIN_VIP_MANAGEMENT),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary, size: 24),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark.withValues(alpha: 0.5),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textDark.withValues(alpha: 0.25),
      ),
    );
  }
}
