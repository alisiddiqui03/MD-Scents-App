import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/data/models/product.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/widgets/discount_badge.dart';
import '../../../../app/widgets/vip_exclusive_corner_badge.dart';
import '../../all_products/controllers/all_products_controller.dart';
import '../controllers/featured_products_controller.dart';

class FeaturedProductsView extends GetView<FeaturedProductsController> {
  const FeaturedProductsView({super.key});

  static const _sheetText = TextStyle(color: Color(0xFF212121), fontSize: 16);
  static const _sheetSub = TextStyle(color: Color(0xFF616161), fontSize: 12);

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
          'FEATURED PICKS',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showFilterSheet(context),
            icon: Obx(() {
              final active = controller.priceFilterActive.value ||
                  controller.selectedSize.value != null;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.tune_rounded, color: AppColors.textDark),
                  if (active)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
      body: Obx(() {
        Future<void> onRefresh() =>
            ProductService.to.refreshCatalogFromServer();
        final h = MediaQuery.sizeOf(context).height;
        final minScroll = (h * 0.55).clamp(320.0, 640.0);

        if (!controller.hasFeaturedProducts) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: minScroll,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No featured products yet.\nMark products as featured from admin.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textDark.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final products = controller.filteredProducts;
        return Column(
          children: [
            _buildCategoryFilter(),
            _buildSizeCategoryFilter(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: onRefresh,
                child: products.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: minScroll,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  controller.priceFilterActive.value ||
                                          (controller
                                                  .selectedCategory
                                                  .value !=
                                              null &&
                                              controller
                                                  .selectedCategory
                                                  .value!
                                                  .isNotEmpty)
                                      ? 'No featured products match your filters.'
                                      : 'No featured products to show.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textDark
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: products.length,
                        itemBuilder: (_, i) =>
                            _FeaturedProductCard(product: products[i]),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showFilterSheet(BuildContext context) {
    controller.syncAppliedRangeToCatalogIfNeeded();
    final bounds = AllProductsController.kPriceBounds;
    var range = controller.priceFilterActive.value
        ? controller.appliedPriceRange.value
        : bounds;
    range = RangeValues(
      range.start.clamp(bounds.start, bounds.end),
      range.end.clamp(bounds.start, bounds.end),
    );
    if (range.start >= range.end) {
      range = bounds;
    }
    AllProductsSort localSort = controller.sort.value;

    final mq = MediaQuery.of(context);
    final maxH = mq.size.height * 0.72;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.white,
      constraints: BoxConstraints(maxHeight: maxH),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 12),
            maintainBottomViewPadding: true,
            child: Theme(
              data: Theme.of(ctx).copyWith(
                canvasColor: Colors.white,
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary,
                  brightness: Brightness.light,
                ),
              ),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        const SizedBox(height: 14),
                        Text(
                          'Filter & sort',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Featured only — price (PKR) effective after discounts (0 – 1,00,000)',
                          style: _sheetSub,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PKR ${range.start.round()}',
                              style: _sheetText.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'PKR ${range.end.round()}',
                              style: _sheetText.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        RangeSlider(
                          values: range,
                          min: bounds.start,
                          max: bounds.end,
                          divisions: 40,
                          labels: RangeLabels(
                            'PKR ${range.start.round()}',
                            'PKR ${range.end.round()}',
                          ),
                          activeColor: AppColors.primary,
                          inactiveColor: Colors.grey.shade300,
                          onChanged: (v) {
                            setModalState(() => range = v);
                          },
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              controller.clearPriceFilter();
                              setModalState(() {
                                range = AllProductsController.kPriceBounds;
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                            child: const Text('Reset price range'),
                          ),
                        ),
                        const Divider(height: 20),
                        Text(
                          'Sort by',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<AllProductsSort>(
                              value: localSort,
                              isExpanded: true,
                              style: _sheetText,
                              iconEnabledColor: const Color(0xFF212121),
                              iconDisabledColor: Colors.grey,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              menuMaxHeight: 280,
                              items: [
                                DropdownMenuItem(
                                  value: AllProductsSort.newest,
                                  child: Text(
                                    'Default order',
                                    style: _sheetText.copyWith(fontSize: 15),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: AllProductsSort.priceLowHigh,
                                  child: Text(
                                    'Price: Low to high',
                                    style: _sheetText.copyWith(fontSize: 15),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: AllProductsSort.priceHighLow,
                                  child: Text(
                                    'Price: High to low',
                                    style: _sheetText.copyWith(fontSize: 15),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: AllProductsSort.nameAZ,
                                  child: Text(
                                    'Name: A–Z',
                                    style: _sheetText.copyWith(fontSize: 15),
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setModalState(() => localSort = v);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF212121),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  controller.applyPriceFilterFromSheet(range);
                                  controller.setSort(localSort);
                                  Navigator.pop(ctx);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Apply'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(() {
      final labels = controller.categoryLabels;
      if (labels.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _categoryChip(
                label: 'All',
                selected: controller.selectedCategory.value == null,
                onTap: () => controller.selectCategory(null),
              ),
              ...labels.map(
                (cat) => _categoryChip(
                  label: cat,
                  selected: controller.selectedCategory.value == cat,
                  onTap: () => controller.selectCategory(cat),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Size category filter row ──────────────────────────────────────────────────

  Widget _buildSizeCategoryFilter() {
    return Obx(() {
      final sizes = [30, 50, 100, 200];
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: Text(
                'Size category',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterChip(
                    label: 'All',
                    selected: controller.selectedSize.value == null,
                    onTap: () => controller.selectSize(null),
                    color: AppColors.accent,
                  ),
                  ...sizes.map(
                    (ml) => _filterChip(
                      label: '${ml}ml',
                      selected: controller.selectedSize.value == ml,
                      onTap: () => controller.selectSize(ml),
                      color: AppColors.accent,
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

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color color = AppColors.primary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? Colors.white : AppColors.textDark,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? Colors.white : AppColors.textDark,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  final ProductItem product;

  const _FeaturedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final effectivePrice = ProductService.to.effectivePrice(product);
    final hasDiscount = effectivePrice < product.price;
    final discountLabel = ProductService.to.discountBadgeLabel(product);
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.USER_PRODUCT_DETAIL,
        arguments: {'id': product.id},
      ),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Center(
                          child: Icon(
                            Icons.water_drop_outlined,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'NEW',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (discountLabel != null) ...[
                          if (product.isNew) const SizedBox(height: 4),
                          DiscountBadge(text: discountLabel),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Featured',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (product.isVipOnly)
                    const Positioned(
                      bottom: 8,
                      left: 8,
                      child: VipExclusiveCornerBadge(),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.unitSize != null && product.unitSize!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${product.unitSize}${product.unitSize!.toLowerCase().contains('ml') ? '' : 'ml'}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasDiscount || product.oldPrice != null)
                            Text(
                              'PKR ${(product.oldPrice ?? product.price).toStringAsFixed(0)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 10,
                                color: AppColors.textDark.withValues(
                                  alpha: 0.4,
                                ),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            'PKR ${effectivePrice.toStringAsFixed(0)}',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
