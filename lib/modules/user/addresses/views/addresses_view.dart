import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class AddressesView extends StatelessWidget {
  const AddressesView({super.key});

  @override
  Widget build(BuildContext context) {
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
          'DELIVERY ADDRESSES',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add New',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          ..._addresses.asMap().entries.map(
                (e) => _AddressCard(
                  address: e.value,
                  isDefault: e.key == 0,
                ),
              ),
        ],
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add New Address', style: AppTextStyles.titleLarge),
            const SizedBox(height: 20),
            _buildField('Full Name', Icons.person_outline),
            const SizedBox(height: 12),
            _buildField('Phone Number', Icons.phone_outlined,
                type: TextInputType.phone),
            const SizedBox(height: 12),
            _buildField('Street Address', Icons.location_on_outlined),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildField('City', Icons.location_city_outlined)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildField('Postal Code', Icons.markunread_mailbox_outlined,
                        type: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Address Saved',
                    'Your new address has been added.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: AppColors.success,
                    colorText: Colors.white,
                    borderRadius: 12,
                    margin: const EdgeInsets.all(12),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text('Save Address', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String hint, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        keyboardType: type,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.35),
          ),
          prefixIcon: Icon(icon,
              color: AppColors.textDark.withValues(alpha: 0.4), size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

class _AddressData {
  final String label;
  final String name;
  final String phone;
  final String address;
  final String city;

  const _AddressData({
    required this.label,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
  });
}

const _addresses = [
  _AddressData(
    label: 'Home',
    name: 'Ali Siddiqui',
    phone: '+92 300 1234567',
    address: 'House 12, Street 5, DHA Phase 2',
    city: 'Lahore, 54000',
  ),
  _AddressData(
    label: 'Office',
    name: 'Ali Siddiqui',
    phone: '+92 321 9876543',
    address: 'Office 3B, Gulberg III, Main Boulevard',
    city: 'Lahore, 54660',
  ),
];

class _AddressCard extends StatelessWidget {
  final _AddressData address;
  final bool isDefault;

  const _AddressCard({required this.address, this.isDefault = false});

  @override
  Widget build(BuildContext context) {
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
                        address.label == 'Home'
                            ? Icons.home_outlined
                            : Icons.business_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      address.label,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
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
                  onSelected: (val) {
                    if (val == 'edit') {
                      Get.snackbar(
                        'Edit Address',
                        'Address editing coming soon.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: AppColors.primary,
                        colorText: Colors.white,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(12),
                      );
                    } else {
                      Get.snackbar(
                        'Address Deleted',
                        '${address.label} address removed.',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: AppColors.primary,
                        colorText: Colors.white,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(12),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete')),
                  ],
                  child: Icon(Icons.more_vert,
                      color: AppColors.textDark.withValues(alpha: 0.4)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.person_outline, address.name),
            const SizedBox(height: 6),
            _infoRow(Icons.phone_outlined, address.phone),
            const SizedBox(height: 6),
            _infoRow(Icons.location_on_outlined, address.address),
            const SizedBox(height: 6),
            _infoRow(Icons.location_city_outlined, address.city),
            if (!isDefault) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Get.snackbar(
                  'Default Updated',
                  '${address.label} set as default address.',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                  borderRadius: 12,
                  margin: const EdgeInsets.all(12),
                ),
                child: Text(
                  'Set as Default',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 15, color: AppColors.textDark.withValues(alpha: 0.4)),
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
