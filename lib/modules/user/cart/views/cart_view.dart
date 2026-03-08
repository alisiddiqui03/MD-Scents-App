import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../../user_base/controllers/user_base_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.find<UserBaseController>().onTabSelected(0);
            }
          },
        ),
        title: Text(
          'CART & CHECKOUT',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.shopping_bag_outlined,
                    color: AppColors.textDark),
              ),
              Positioned(
                top: 8,
                right: 12,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Obx(
                      () => Text(
                        '${controller.items.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCartItems(),
                  const SizedBox(height: 24),
                  _buildPaymentOptions(),
                  const SizedBox(height: 24),
                  _buildOrderSummary(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildCheckoutBar(),
        ],
      ),
    );
  }

  // ── Cart items ──────────────────────────────────────────────────────────────

  Widget _buildCartItems() {
    return Obx(
      () => Column(
        children: controller.items
            .map((item) => _CartItemCard(item: item, controller: controller))
            .toList(),
      ),
    );
  }

  // ── Payment options ─────────────────────────────────────────────────────────

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method', style: AppTextStyles.titleLarge),
        const SizedBox(height: 16),
        Obx(
          () => Column(
            children: [
              // COD
              _PaymentTile(
                icon: Icons.money_outlined,
                label: 'Cash on Delivery',
                sublabel: 'Pay when you receive',
                selected:
                    controller.selectedPayment.value == PaymentMethod.cod,
                onTap: () => controller.selectPayment(PaymentMethod.cod),
              ),
              const SizedBox(height: 12),
              // Bank Transfer
              _PaymentTile(
                icon: Icons.account_balance_outlined,
                label: 'Bank Transfer',
                sublabel: 'Upload payment receipt',
                selected: controller.selectedPayment.value ==
                    PaymentMethod.bankTransfer,
                onTap: () =>
                    controller.selectPayment(PaymentMethod.bankTransfer),
              ),
              // Receipt upload — only shown when Bank Transfer selected
              if (controller.selectedPayment.value ==
                  PaymentMethod.bankTransfer) ...[
                const SizedBox(height: 12),
                _buildBankDetails(),
                const SizedBox(height: 12),
                _buildReceiptUpload(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer to this account:',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _bankRow('Bank', 'HBL / Meezan Bank'),
          const SizedBox(height: 6),
          _bankRow('Account Name', 'MD Scents'),
          const SizedBox(height: 6),
          _bankRow('Account No.', '0123-4567890-01'),
          const SizedBox(height: 6),
          _bankRow('IBAN', 'PK36HABB0000000123456702'),
        ],
      ),
    );
  }

  Widget _bankRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptUpload() {
    return GestureDetector(
      onTap: controller.uploadReceipt,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.upload_file_outlined,
                  color: AppColors.secondary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Payment Receipt',
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Take a screenshot of your transfer and upload it here.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Icon(
                controller.receiptUploaded.value
                    ? Icons.check_circle
                    : Icons.chevron_right,
                color: controller.receiptUploaded.value
                    ? AppColors.success
                    : AppColors.textDark.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Order summary ───────────────────────────────────────────────────────────

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: controller.subtotal),
          const Divider(height: 20),
          Obx(
            () => _SummaryRow(
              label: 'Total',
              value: controller.total,
              isTotal: true,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom checkout bar ─────────────────────────────────────────────────────

  Widget _buildCheckoutBar() {
    return Obx(() {
      final isBankTransfer =
          controller.selectedPayment.value == PaymentMethod.bankTransfer;
      final receiptReady = controller.receiptUploaded.value;
      final canPlace = !isBankTransfer || receiptReady;
      final label = isBankTransfer ? 'Confirm Order' : 'Place Order';

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBankTransfer && !receiptReady)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.textDark.withValues(alpha: 0.45)),
                    const SizedBox(width: 6),
                    Text(
                      'Please upload your payment receipt first.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        color: AppColors.textDark.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            GestureDetector(
              onTap: canPlace ? controller.placeOrder : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  gradient: canPlace
                      ? const LinearGradient(
                          colors: [AppColors.secondary, AppColors.primary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: canPlace
                      ? null
                      : AppColors.textDark.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: canPlace
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.buttonText.copyWith(
                      color: canPlace
                          ? Colors.white
                          : AppColors.textDark.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Cart item card ────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartController controller;

  const _CartItemCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(
      int.parse('FF${item.imagePlaceholder}', radix: 16),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.water_drop_rounded,
                color: bgColor.withValues(alpha: 0.8),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'PKR ${item.price.toStringAsFixed(0)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDark.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),

          // Qty + price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => controller.removeItem(item.id),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.textDark.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  'PKR ${(item.price * item.qty.value).toStringAsFixed(0)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Payment tile ──────────────────────────────────────────────────────────────

class _PaymentTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: selected ? AppColors.primary : Colors.grey.shade500,
                  size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textDark,
                ),
              ),
            ),
            if (sublabel.isNotEmpty)
              Text(
                sublabel,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.55),
                ),
              ),
            const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.titleLarge.copyWith(fontSize: 16)
              : AppTextStyles.bodyLarge,
        ),
        Text(
          'PKR ${value.toStringAsFixed(0)}',
          style: isTotal
              ? AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary, fontSize: 18)
              : AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
