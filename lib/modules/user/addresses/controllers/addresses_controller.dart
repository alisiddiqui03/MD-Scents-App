import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/data/models/delivery_address.dart';
import '../../../../app/services/address_service.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class AddressesController extends GetxController {
  final AddressService _addressService = AddressService.to;
  final AuthService _auth = AuthService.to;

  final addresses = <DeliveryAddress>[].obs;
  final isSaving = false.obs;
  final setAsDefault = false.obs;

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final postalController = TextEditingController();
  final label = 'Home'.obs;

  /// Null = add mode, non-null = edit id
  final editingId = Rxn<String>();

  StreamSubscription<List<DeliveryAddress>>? _addrSub;

  String? get _uid => _auth.currentUser.value?.uid;

  @override
  void onInit() {
    super.onInit();
    ever(_auth.currentUser, (_) => _listenAddresses());
    if (_auth.currentUser.value != null) {
      _listenAddresses();
    }
  }

  void _listenAddresses() {
    _addrSub?.cancel();
    final uid = _uid;
    if (uid == null) {
      addresses.clear();
      return;
    }
    _addrSub = _addressService.addressesStream(uid).listen((list) {
      addresses.assignAll(list);
    });
  }

  void clearForm() {
    fullNameController.clear();
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    postalController.clear();
    label.value = 'Home';
    setAsDefault.value = false;
    editingId.value = null;
  }

  void loadForEdit(DeliveryAddress a) {
    editingId.value = a.id;
    label.value = a.label;
    fullNameController.text = a.fullName;
    phoneController.text = a.phone;
    streetController.text = a.street;
    cityController.text = a.city;
    postalController.text = a.postalCode;
    setAsDefault.value = a.isDefault;
  }

  Future<void> saveAddress() async {
    final uid = _uid;
    if (uid == null) {
      _snack('Login required', 'Please sign in to save addresses.');
      return;
    }

    final name = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final street = streetController.text.trim();
    final city = cityController.text.trim();
    final postal = postalController.text.trim();

    if (name.isEmpty || phone.isEmpty || street.isEmpty || city.isEmpty) {
      _snack('Missing fields', 'Name, phone, street and city are required.');
      return;
    }

    isSaving.value = true;
    try {
      final id = editingId.value;
      if (id == null) {
        await _addressService.addAddress(
          uid: uid,
          label: label.value,
          fullName: name,
          phone: phone,
          street: street,
          city: city,
          postalCode: postal,
          setAsDefault: setAsDefault.value,
        );
        _snack('Saved', 'Address added.');
      } else {
        final matches = addresses.where((e) => e.id == id).toList();
        if (matches.isEmpty) return;
        final existing = matches.first;
        await _addressService.updateAddress(
          uid: uid,
          existing: existing,
          label: label.value,
          fullName: name,
          phone: phone,
          street: street,
          city: city,
          postalCode: postal,
          setAsDefault: setAsDefault.value,
        );
        _snack('Updated', 'Address saved.');
      }
      _closeAddressSheet();
      clearForm();
    } catch (e) {
      _snack('Error', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAddress(DeliveryAddress a) async {
    final uid = _uid;
    if (uid == null) return;

    final ok = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete address?', style: AppTextStyles.titleLarge),
        content: Text(
          'Remove "${a.label}" from your saved addresses?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.65),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textDark.withValues(alpha: 0.5),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _addressService.deleteAddress(uid, a.id);
      _snack('Removed', 'Address deleted.');
    } catch (e) {
      _snack('Error', e.toString());
    }
  }

  Future<void> setDefault(DeliveryAddress a) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _addressService.setDefaultAddress(uid, a.id);
      _snack('Default updated', '${a.label} is now your default address.');
    } catch (e) {
      _snack('Error', e.toString());
    }
  }

  void _closeAddressSheet() {
    final ctx = Get.context;
    if (ctx == null) return;
    final nav = Navigator.of(ctx, rootNavigator: true);
    if (nav.canPop()) {
      nav.pop();
    }
  }

  Future<void> refreshAddresses() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final list = await _addressService.fetchAddressesOnce(uid);
      addresses.assignAll(list);
    } catch (_) {}
  }

  void _snack(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
    );
  }

  @override
  void onClose() {
    _addrSub?.cancel();
    fullNameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    postalController.dispose();
    super.onClose();
  }
}
