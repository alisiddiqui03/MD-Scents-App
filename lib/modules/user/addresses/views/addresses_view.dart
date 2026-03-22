import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/models/delivery_address.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/addresses_controller.dart';

class AddressesView extends GetView<AddressesController> {
  const AddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
            size: 18,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'DELIVERY ADDRESSES',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      floatingActionButton: Obx(() {
        final loggedIn = AuthService.to.currentUser.value != null;
        if (!loggedIn) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () {
            controller.clearForm();
            _showAddressSheet(context);
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add New',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
        );
      }),
      body: Obx(() {
        final user = AuthService.to.currentUser.value;
        if (user == null) {
          return _loginPrompt(context);
        }
        final list = controller.addresses;
        if (list.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.refreshAddresses(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: _emptyState(context),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.refreshAddresses(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: list
                .map(
                  (a) => _AddressCard(
                    address: a,
                    controller: controller,
                    onEdit: () {
                      controller.loadForEdit(a);
                      _showAddressSheet(context);
                    },
                  ),
                )
                .toList(),
          ),
        );
      }),
    );
  }

  Widget _loginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login_rounded,
              size: 56,
              color: AppColors.textDark.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to manage addresses',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Your saved delivery addresses sync with your account.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Get.toNamed(Routes.AUTH),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: const Text('Go to login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 56,
              color: AppColors.textDark.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              'No addresses yet',
              style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap Add New to save a delivery address.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _fieldBorderColor = Color(0xFF9E9E9E);
  static const _fieldBorderWidth = 1.25;

  void _showAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final mq = MediaQuery.of(sheetContext);
        final kb = mq.viewInsets.bottom;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: kb),
          child: SafeArea(
            top: false,
            maintainBottomViewPadding: true,
            minimum: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Obx(() {
                final isEdit = controller.editingId.value != null;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isEdit ? 'Edit Address' : 'Add New Address',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Label',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _fieldBorderColor,
                            width: _fieldBorderWidth,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: controller.label.value,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            iconEnabledColor: Colors.black87,
                            iconDisabledColor: Colors.black45,
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            menuMaxHeight: 280,
                            items: [
                              DropdownMenuItem(
                                value: 'Home',
                                child: Text(
                                  'Home',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Office',
                                child: Text(
                                  'Office',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text(
                                  'Other',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) controller.label.value = v;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      'Full Name',
                      Icons.person_outline,
                      controller.fullNameController,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      'Phone Number',
                      Icons.phone_outlined,
                      controller.phoneController,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      'Street Address',
                      Icons.location_on_outlined,
                      controller.streetController,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            'City',
                            Icons.location_city_outlined,
                            controller.cityController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            'Postal Code',
                            Icons.markunread_mailbox_outlined,
                            controller.postalController,
                            type: TextInputType.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Set as default address',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: controller.setAsDefault.value,
                        activeColor: AppColors.primary,
                        checkColor: Colors.white,
                        side: const BorderSide(
                          color: _fieldBorderColor,
                          width: _fieldBorderWidth,
                        ),
                        onChanged: (v) =>
                            controller.setAsDefault.value = v ?? false,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : () => controller.saveAddress(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.5),
                          ),
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isEdit ? 'Update Address' : 'Save Address',
                                  style: AppTextStyles.buttonText,
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(
    String hint,
    IconData icon,
    TextEditingController c, {
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _fieldBorderColor, width: _fieldBorderWidth),
      ),
      child: TextField(
        controller: c,
        keyboardType: type,
        autocorrect: false,
        style: AppTextStyles.bodyLarge.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Colors.black54, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final AddressesController controller;
  final VoidCallback onEdit;

  const _AddressCard({
    required this.address,
    required this.controller,
    required this.onEdit,
  });

  IconData _labelIcon(String label) {
    final l = label.toLowerCase();
    if (l == 'home') return Icons.home_outlined;
    if (l == 'office') return Icons.business_outlined;
    return Icons.place_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isDefault = address.isDefault;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDefault
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _labelIcon(address.label),
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      address.label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Default',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                PopupMenuButton<String>(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  onSelected: (val) async {
                    if (val == 'edit') {
                      onEdit();
                    } else if (val == 'delete') {
                      await controller.deleteAddress(address);
                    } else if (val == 'default') {
                      await controller.setDefault(address);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text(
                        'Edit',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!isDefault)
                      PopupMenuItem<String>(
                        value: 'default',
                        child: Text(
                          'Set as default',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textDark.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.person_outline, address.fullName),
            const SizedBox(height: 6),
            _infoRow(Icons.phone_outlined, address.phone),
            const SizedBox(height: 6),
            _infoRow(Icons.location_on_outlined, address.street),
            const SizedBox(height: 6),
            _infoRow(Icons.location_city_outlined, address.cityLine),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textDark.withValues(alpha: 0.4)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
