import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/inventory_controller.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/data/models/product.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/widgets/loading_overlay.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory & Discounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.refreshFromService,
          ),
        ],
      ),
      body: Obx(
        () => LoadingOverlay(
          isLoading: controller.isDeleting.value,
          title: 'Removing product',
          subtitle: 'Updating your inventory…',
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final items = controller.items;
              final loading =
                  ProductService.to.isProductsLoading.value && items.isEmpty;

              if (loading) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ProductService.to.refreshCatalogFromServer(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                  color: AppColors.primary),
                              const SizedBox(height: 16),
                              Text(
                                'Loading inventory...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textDark.withValues(
                                      alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (items.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ProductService.to.refreshCatalogFromServer(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.45,
                        child: Center(
                          child: Text(
                            'No products in inventory yet.\nTap "Add product" to create one.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textDark.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final filtered = controller.filteredItems;
              final hasSearch = controller.searchQuery.value.trim().isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchBar(controller: controller),
                  const SizedBox(height: 12),
                  _AdminDiscountCard(),
                  const SizedBox(height: 16),
                  Text(
                    'Total stock: ${controller.totalItems}'
                    '${hasSearch ? ' • ${filtered.length} shown' : ''}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () =>
                                ProductService.to.refreshCatalogFromServer(),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.35,
                                  child: Center(
                                    child: Text(
                                      'No products match "${controller.searchQuery.value.trim()}".\nTry a different name.',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textDark.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () =>
                                ProductService.to.refreshCatalogFromServer(),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) =>
                                  _InventoryTile(product: filtered[i]),
                            ),
                          ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final InventoryController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDark,
          fontSize: 15,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: 'Search products by name',
          hintStyle: TextStyle(
            color: AppColors.textDark.withValues(alpha: 0.38),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primary.withValues(alpha: 0.75),
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              tooltip: 'Clear',
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textDark.withValues(alpha: 0.45),
              ),
              onPressed: controller.clearSearch,
            );
          }),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _AdminDiscountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetX<InventoryController>(
      builder: (c) {
        final base = c.adBasePercent.value;
        final max = c.adMaxPercent.value;
        final progress = (base - 5) / (max - 5).clamp(1, 100);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1F2A44), Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ads & Discount',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Switch(
                    value: c.adsEnabled.value,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.white.withValues(alpha: 0.45),
                    onChanged: (v) => c.adsEnabled.value = v,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Base discount: ${base.toStringAsFixed(0)}% • Max with ads: ${max.toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['5%', '10%', '15%', '20%']
                    .map(
                      (t) => Text(
                        t,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showAdsConfigSheet(c),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Manage ads flow'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAdsConfigSheet(InventoryController c) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
            const SizedBox(height: 16),
            Text('Ads discount flow', style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Configure how much extra discount a user can unlock by watching rewarded ads.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Base discount: ${c.adBasePercent.value.toStringAsFixed(0)}%',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Slider(
                    value: c.adBasePercent.value,
                    min: 5,
                    max: 20,
                    divisions: 3,
                    label: '${c.adBasePercent.value.toStringAsFixed(0)}%',
                    onChanged: (v) => c.adBasePercent.value = v,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Max discount with ads: ${c.adMaxPercent.value.toStringAsFixed(0)}%',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Slider(
                    value: c.adMaxPercent.value,
                    min: 10,
                    max: 25,
                    divisions: 3,
                    label: '${c.adMaxPercent.value.toStringAsFixed(0)}%',
                    onChanged: (v) => c.adMaxPercent.value = v,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Extra per ad watched: +${c.adPerAdBoost.value.toStringAsFixed(0)}%',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Slider(
                    value: c.adPerAdBoost.value,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '+${c.adPerAdBoost.value.toStringAsFixed(0)}%',
                    onChanged: (v) => c.adPerAdBoost.value = v,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Note: This is mock config. Later it will be tied\nto Firebase + AdMob for real rewarded ads.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  final ProductItem product;

  const _InventoryTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final th = ProductService.to.lowStockThreshold.value;
      final lowStock = product.stock <= th;
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary.withValues(alpha: 0.06),
                ),
                child: Center(
                  child: Text(
                    product.name.isNotEmpty ? product.name[0] : '?',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PKR ${product.price.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 14,
                          color: lowStock
                              ? AppColors.danger
                              : AppColors.textDark.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stock: ${product.stock}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: lowStock
                                ? AppColors.danger
                                : AppColors.textDark.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.discountPercent > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '-${product.discountPercent.toStringAsFixed(0)}%',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: product.isActive
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.textDark.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            product.isActive ? 'Active' : 'Hidden',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: product.isActive
                                  ? AppColors.success
                                  : AppColors.textDark.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _TileActions(product: product),
            ],
          ),
        ),
      );
    });
  }
}

class _TileActions extends GetView<InventoryController> {
  final ProductItem product;

  const _TileActions({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () {
            Get.toNamed(
              Routes.ADMIN_UPLOAD_PRODUCT,
              arguments: {'id': product.id},
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: AppColors.danger,
          onPressed: () async {
            final confirmed =
                await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete product'),
                    content: Text(
                      'Are you sure you want to delete "${product.name}"?',
                      style: AppTextStyles.bodyMedium,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ) ??
                false;
            if (confirmed) {
              await controller.deleteProduct(product);
            }
          },
        ),
      ],
    );
  }
}
