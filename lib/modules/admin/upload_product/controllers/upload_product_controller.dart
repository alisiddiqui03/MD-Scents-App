import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/config/cloudinary_config.dart';
import '../../../../app/data/models/product.dart';
import '../../../../app/services/cloudinary_service.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/utils/admin_snackbar.dart';

class UploadProductController extends GetxController {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final discountController = TextEditingController();
  final isFeatured = false.obs;
  final isActive = true.obs;

  final isSaving = false.obs;
  final isUploadingImage = false.obs;

  /// Uploaded image URLs (order = gallery order).
  final imageUrls = <String>[].obs;

  final ImagePicker _picker = ImagePicker();

  final ProductService _productService = ProductService.to;
  final CloudinaryService _cloudinary = CloudinaryService();

  String? _editingId;

  bool get isEditing => _editingId != null;
  bool get cloudinaryConfigured => CloudinaryConfig.isConfigured;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final id = args?['id'] as String?;
    if (id != null) {
      final existing = _productService.findById(id);
      if (existing != null) {
        _editingId = existing.id;
        nameController.text = existing.name;
        priceController.text = existing.price.toStringAsFixed(0);
        stockController.text = existing.stock.toString();
        discountController.text = existing.discountPercent.toStringAsFixed(0);
        imageUrls.assignAll(existing.imageUrls);
        if (imageUrls.isEmpty && existing.imageUrl.isNotEmpty) {
          imageUrls.add(existing.imageUrl);
        }
        isFeatured.value = existing.isFeatured;
        isActive.value = existing.isActive;
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
    super.onClose();
  }

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
        e.toString().replaceFirst('StateError: ', '').replaceFirst('Exception: ', ''),
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

  void clearAllImages() {
    imageUrls.clear();
  }

  Future<void> saveProduct() async {
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();
    final stockText = stockController.text.trim();
    final discountText = discountController.text.trim();

    if (name.isEmpty || priceText.isEmpty || stockText.isEmpty) {
      AdminSnackbar.error(
        'Missing information',
        'Name, price and stock are required.',
      );
      return;
    }

    final price = double.tryParse(priceText);
    final stock = int.tryParse(stockText);
    final discount = double.tryParse(discountText.isEmpty ? '0' : discountText);
    if (price == null || stock == null || discount == null) {
      AdminSnackbar.error(
        'Invalid values',
        'Please enter valid numbers for price, stock and discount.',
      );
      return;
    }
    final safeDiscount = discount.clamp(0, 90).toDouble();

    isSaving.value = true;
    try {
      final id = _editingId ??
          'p-${DateTime.now().millisecondsSinceEpoch.toString()}';

      final urls = imageUrls.isNotEmpty
          ? List<String>.from(imageUrls)
          : <String>[
              'https://picsum.photos/seed/$id/400/400',
            ];

      final desc = descriptionController.text.trim();
      final product = ProductItem(
        id: id,
        name: name,
        price: price,
        imageUrls: urls,
        stock: stock,
        isActive: isActive.value,
        discountPercent: safeDiscount,
        isFeatured: isFeatured.value,
        description: desc.isEmpty ? null : desc,
      );

      await _productService.upsertProduct(product);

      Get.back(); // close form

      AdminSnackbar.success(
        isEditing ? 'Product updated' : 'Product created',
        '$name has been saved.',
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
