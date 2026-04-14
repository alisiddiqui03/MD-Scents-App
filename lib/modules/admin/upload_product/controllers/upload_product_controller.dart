import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/config/cloudinary_config.dart';
import '../../../../app/data/models/brand.dart';
import '../../../../app/data/models/product.dart';
import '../../../../app/services/brand_service.dart';
import '../../../../app/services/cloudinary_service.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/utils/admin_snackbar.dart';

/// Fixed size options (ml) available for selection.
const List<int> kSizeOptions = [30, 50, 100, 200];

class UploadProductController extends GetxController {
  // ── Text controllers ────────────────────────────────────────────────────────
  /// Perfume name only (e.g. "Aventus"). Brand is selected separately.
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final discountController = TextEditingController();
  final unitSizeController = TextEditingController();

  // ── Toggles ─────────────────────────────────────────────────────────────────
  final isFeatured = false.obs;
  final isActive = true.obs;

  // ── Size (ml) ────────────────────────────────────────────────────────────────
  /// Selected ml from [kSizeOptions]. Required before saving.
  final selectedSize = Rxn<int>();

  // ── Brand ───────────────────────────────────────────────────────────────────
  /// Selected brand name (String) or null when none.
  final selectedBrand = Rxn<String>();

  /// When true, show the inline "Add new brand" input row.
  final isAddingNewBrand = false.obs;

  /// Input for the new brand name when [isAddingNewBrand] is true.
  final newBrandController = TextEditingController();

  /// Prevents double-tap while saving a new brand to Firestore.
  final isSavingBrand = false.obs;

  // ── Loading / saving ────────────────────────────────────────────────────────
  final isSaving = false.obs;
  final isUploadingImage = false.obs;

  /// Uploaded image URLs (order = gallery order).
  final imageUrls = <String>[].obs;

  // ── Internals ────────────────────────────────────────────────────────────────
  final ImagePicker _picker = ImagePicker();
  final ProductService _productService = ProductService.to;
  final CloudinaryService _cloudinary = CloudinaryService();

  String? _editingId;

  bool get isEditing => _editingId != null;
  bool get cloudinaryConfigured => CloudinaryConfig.isConfigured;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String?;
    if (id != null) {
      final existing = _productService.findById(id);
      if (existing != null) {
        _editingId = existing.id;

        // ── Name: strip brand prefix so input shows perfume name only ─────────
        final brand = existing.brandName;
        if (brand != null && brand.isNotEmpty) {
          selectedBrand.value = brand;
          final prefix = '$brand ';
          nameController.text = existing.name.startsWith(prefix)
              ? existing.name.substring(prefix.length)
              : existing.name;
        } else {
          nameController.text = existing.name;
        }

        priceController.text = existing.price.toStringAsFixed(0);
        stockController.text = existing.stock.toString();
        discountController.text = existing.discountPercent > 0
            ? existing.discountPercent.toStringAsFixed(0)
            : '';
        descriptionController.text = existing.description ?? '';

        imageUrls.assignAll(existing.imageUrls);
        if (imageUrls.isEmpty && existing.imageUrl.isNotEmpty) {
          imageUrls.add(existing.imageUrl);
        }

        isFeatured.value = existing.isFeatured;
        isActive.value = existing.isActive;
        selectedSize.value = existing.size;
        unitSizeController.text = existing.unitSize ?? '';
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    discountController.dispose();
    newBrandController.dispose();
    unitSizeController.dispose();
    super.onClose();
  }

  // ── Brand helpers ────────────────────────────────────────────────────────────

  void startAddingNewBrand() {
    newBrandController.clear();
    isAddingNewBrand.value = true;
  }

  void cancelAddingBrand() {
    isAddingNewBrand.value = false;
    newBrandController.clear();
  }

  Future<void> saveNewBrand() async {
    final name = newBrandController.text.trim();
    if (name.isEmpty) {
      AdminSnackbar.error('Brand name required', 'Enter a brand name first.');
      return;
    }
    if (isSavingBrand.value) return;
    isSavingBrand.value = true;
    try {
      final brand = await BrandService.to.addBrand(name);
      if (brand != null) {
        selectedBrand.value = brand.name;
        isAddingNewBrand.value = false;
        newBrandController.clear();
        AdminSnackbar.success('Brand saved', '"${brand.name}" is now available.');
      }
    } catch (e) {
      AdminSnackbar.error(
        'Could not save brand',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isSavingBrand.value = false;
    }
  }

  // ── Image helpers ────────────────────────────────────────────────────────────

  /// Pick one or more images from gallery, upload each to Cloudinary.
  Future<void> pickAndUploadImages() async {
    if (!cloudinaryConfigured) {
      AdminSnackbar.error(
        'Cloudinary not configured',
        'Set cloudName and uploadPreset in lib/app/config/cloudinary_config.dart',
      );
      return;
    }

    if (isUploadingImage.value) return;
    isUploadingImage.value = true;

    try {
      final files = await _picker.pickMultiImage(
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (files.isEmpty) return;

      var uploaded = 0;
      for (final xFile in files) {
        final file = File(xFile.path);
        if (!await file.exists()) continue;
        final url = await _cloudinary.uploadImage(file);
        imageUrls.add(url);
        uploaded++;
      }

      if (uploaded > 0) {
        AdminSnackbar.success(
          'Images uploaded',
          '$uploaded image(s) added. Save the product to publish.',
        );
      }
    } catch (e) {
      AdminSnackbar.error(
        'Upload failed',
        e.toString()
            .replaceFirst('StateError: ', '')
            .replaceFirst('Exception: ', ''),
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  void removeImageAt(int index) {
    if (index >= 0 && index < imageUrls.length) {
      imageUrls.removeAt(index);
    }
  }

  void clearAllImages() => imageUrls.clear();

  // ── Save ─────────────────────────────────────────────────────────────────────

  Future<void> saveProduct() async {
    final perfumeName = nameController.text.trim();
    final priceText = priceController.text.trim();
    final stockText = stockController.text.trim();
    final discountText = discountController.text.trim();

    // ── Validation ────────────────────────────────────────────────────────────
    if (perfumeName.isEmpty || priceText.isEmpty || stockText.isEmpty) {
      AdminSnackbar.error(
        'Missing information',
        'Perfume name, price and stock are required.',
      );
      return;
    }

    if (selectedSize.value == null) {
      AdminSnackbar.error(
        'Size required',
        'Please select a perfume size (ml).',
      );
      return;
    }

    final price = double.tryParse(priceText);
    final stock = int.tryParse(stockText);
    // Treat empty discount as 0
    final discount =
        double.tryParse(discountText.isEmpty ? '0' : discountText);

    if (price == null || stock == null || discount == null) {
      AdminSnackbar.error(
        'Invalid values',
        'Please enter valid numbers for price, stock and discount.',
      );
      return;
    }
    final safeDiscount = discount.clamp(0, 90).toDouble();

    // ── Build display name ─────────────────────────────────────────────────────
    // "Creed" + "Aventus" → "Creed Aventus"; no brand → just "Aventus"
    final brand = selectedBrand.value?.trim();
    final displayName = (brand != null && brand.isNotEmpty)
        ? '$brand $perfumeName'
        : perfumeName;

    isSaving.value = true;
    try {
      final id = _editingId ??
          'p-${DateTime.now().millisecondsSinceEpoch.toString()}';

      final urls = imageUrls.isNotEmpty
          ? List<String>.from(imageUrls)
          : <String>['https://picsum.photos/seed/$id/400/400'];

      final desc = descriptionController.text.trim();
      final product = ProductItem(
        id: id,
        name: displayName,
        price: price,
        imageUrls: urls,
        stock: stock,
        isActive: isActive.value,
        discountPercent: safeDiscount,
        isFeatured: isFeatured.value,
        description: desc.isEmpty ? null : desc,
        size: selectedSize.value,
        brandName: (brand != null && brand.isNotEmpty) ? brand : null,
        unitSize: unitSizeController.text.trim(),
      );

      await _productService.upsertProduct(product);

      Get.back();

      AdminSnackbar.success(
        isEditing ? 'Product updated' : 'Product created',
        '$displayName has been saved.',
      );
    } catch (e) {
      AdminSnackbar.error(
        'Could not save product',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isSaving.value = false;
    }
  }
}
