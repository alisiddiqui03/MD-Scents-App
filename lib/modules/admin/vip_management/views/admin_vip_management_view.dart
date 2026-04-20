import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/admin_vip_management_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class AdminVipManagementView extends GetView<AdminVipManagementController> {
  const AdminVipManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('VIP Management')),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 350));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            children: [
              _requestsSection(),
              const SizedBox(height: 14),
              _searchAndFilters(),
              const SizedBox(height: 10),
              _allUsersSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchAndFilters() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.searchController,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.45),
                ),
                hintText: 'Search by name or UID…',
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip('All Users', VipUserListFilter.all),
                _filterChip('VIP Only', VipUserListFilter.vipOnly),
                _filterChip('Non-VIP', VipUserListFilter.nonVip),
                _filterChip(
                  'Pending requests',
                  VipUserListFilter.pendingRequests,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, VipUserListFilter value) {
    return Obx(() {
      final sel = controller.userListFilter.value == value;
      return FilterChip(
        label: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: sel ? Colors.white : AppColors.textDark,
          ),
        ),
        selected: sel,
        onSelected: (_) => controller.userListFilter.value = value,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.grey.shade100,
      );
    });
  }

  Widget _requestsSection() {
    return Obx(() {
      if (controller.isRequestsLoading.value) {
        return _card(
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      }
      controller.vipRequests.length;
      final rows = controller.vipRequests;
      return _card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pending VIP Requests', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 4),
              Text(
                rows.isEmpty
                    ? 'No pending requests.'
                    : 'Users who submitted payment screenshot.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
              if (rows.isNotEmpty) const SizedBox(height: 10),
              ...rows.map((r) => _requestTile(r)),
            ],
          ),
        ),
      );
    });
  }

  Widget _requestTile(VipRequestRow r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.displayName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  r.planType == 'yearly' ? 'Yearly' : 'Monthly',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          if (r.userEmail != null && r.userEmail!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              r.userEmail!.trim(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 11,
                color: AppColors.textDark.withValues(alpha: 0.55),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            'UID: ${r.uid.length > 18 ? r.uid.substring(0, 18) : r.uid}…',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 10,
              color: AppColors.textDark.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: r.screenshotUrl.isEmpty
                      ? null
                      : () => _openScreenshot(r.screenshotUrl),
                  icon: const Icon(Icons.image_outlined, size: 16),
                  label: const Text('View screenshot'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() {
                  final busy = controller.actionUid.value == r.uid;
                  return FilledButton.icon(
                    onPressed: busy ? null : () => controller.approveRequest(r),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.verified_rounded, size: 16),
                    label: Text(busy ? 'Approving...' : 'Approve & Activate'),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _allUsersSection(BuildContext context) {
    return Obx(() {
      if (controller.isUsersLoading.value) {
        return _card(
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      }
      controller.users.length;
      controller.vipRequests.length;
      controller.userListFilter.value;
      controller.searchQuery.value;
      final rows = controller.filteredUsers();
      return _card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Users', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 4),
              Text(
                rows.isEmpty
                    ? 'No users match this filter.'
                    : '${rows.length} user${rows.length == 1 ? '' : 's'}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              ...rows.map((u) => _userTile(context, u)),
            ],
          ),
        ),
      );
    });
  }

  String _vipStatusLine(VipUserRow u) {
    final active = controller.isVipActive(u);
    if (!active) {
      if (u.isVip) return 'VIP Status: Expired';
      return 'VIP Status: Not VIP';
    }
    final t = (u.vipType ?? '').toLowerCase();
    if (t == 'yearly') return 'VIP Status: VIP Yearly';
    if (t == 'monthly') return 'VIP Status: VIP Monthly';
    return 'VIP Status: VIP';
  }

  Widget _userTile(BuildContext context, VipUserRow u) {
    final active = controller.isVipActive(u);
    final email = (u.email != null && u.email!.trim().isNotEmpty)
        ? u.email!.trim()
        : '—';
    final until = u.vipEndDate != null
        ? DateFormat('dd MMM yyyy').format(u.vipEndDate!)
        : '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            u.displayName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              color: AppColors.textDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _vipStatusLine(u),
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark.withValues(alpha: 0.75),
            ),
          ),
          if (active) ...[
            const SizedBox(height: 4),
            Text(
              'VIP until: $until',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 11,
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'UID: ${u.uid.length > 14 ? u.uid.substring(0, 14) : u.uid}…',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 10,
              color: AppColors.textDark.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final busy = controller.actionUid.value == u.uid;
            if (!active) {
              return SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy
                      ? null
                      : () => _openVipPlanDialog(
                          context,
                          u,
                          title: 'Activate VIP',
                          confirmLabel: 'Activate',
                        ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Activate VIP'),
                ),
              );
            }
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy
                        ? null
                        : () => _openVipPlanDialog(
                            context,
                            u,
                            title: 'Update VIP',
                            confirmLabel: 'Update',
                          ),
                    child: const Text('Update VIP'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: busy
                        ? null
                        : () => _confirmDeactivate(context, u),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Deactivate'),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context, VipUserRow u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Deactivate VIP?', style: AppTextStyles.titleLarge),
        content: Text(
          'Turn off VIP for ${u.displayName}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.deactivateVip(uid: u.uid, userLabel: u.displayName);
    }
  }

  void _openVipPlanDialog(
    BuildContext context,
    VipUserRow u, {
    required String title,
    required String confirmLabel,
  }) {
    String selected = (u.vipType == 'yearly') ? 'yearly' : 'monthly';
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title, style: AppTextStyles.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                u.displayName,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'monthly', label: Text('Monthly')),
                  ButtonSegment(value: 'yearly', label: Text('Yearly')),
                ],
                selected: {selected},
                onSelectionChanged: (s) => setState(() => selected = s.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await controller.activateVip(
                  uid: u.uid,
                  vipType: selected,
                  userLabel: u.displayName,
                );
              },
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _openScreenshot(String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(14),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 240,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
