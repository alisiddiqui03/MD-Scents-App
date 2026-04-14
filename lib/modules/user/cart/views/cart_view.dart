import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_controller.dart';
import '../../user_base/controllers/user_base_controller.dart';
import '../../../../app/config/referral_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/services/discount_service.dart';
import '../../../../app/services/product_service.dart';
import '../../../../app/services/wallet_service.dart';

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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
            size: 18,
          ),
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
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.textDark,
                ),
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
                          fontWeight: FontWeight.w700,
                        ),
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
                  _buildDeliverySection(),
                  const SizedBox(height: 24),
                  _buildPaymentOptions(),
                  const SizedBox(height: 24),
                  _buildReferralAndWalletSection(),
                  const SizedBox(height: 24),
                  _buildOrderSummary(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            maintainBottomViewPadding: true,
            minimum: EdgeInsets.zero,
            child: _buildCheckoutBar(),
          ),
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

  // ── Delivery ────────────────────────────────────────────────────────────────

  static final TextStyle _deliveryInputTextStyle = AppTextStyles.bodyLarge
      .copyWith(
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  InputDecoration _deliveryFieldDecoration({
    required String label,
    String? hint,
  }) {
    final borderRadius = BorderRadius.circular(12);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textDark.withValues(alpha: 0.62),
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textDark.withValues(alpha: 0.38),
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text('Delivery details', style: AppTextStyles.titleLarge),
            ),
            Obx(() {
              final loggedIn = AuthService.to.currentUser.value != null;
              if (!loggedIn) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => controller.openDeliveryAddressPicker(),
                icon: Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.secondary,
                ),
                label: Text(
                  'Saved / new',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(left: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Phone and street are required. Tap Saved / new anytime to switch address.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.deliveryPhoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          style: _deliveryInputTextStyle,
          cursorColor: AppColors.primary,
          onChanged: (_) => controller.notifyDeliveryChanged(),
          decoration: _deliveryFieldDecoration(
            label: 'Phone number *',
            hint: '03xx-xxxxxxx',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.deliveryStreetController,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          maxLines: 2,
          style: _deliveryInputTextStyle,
          cursorColor: AppColors.primary,
          onChanged: (_) => controller.notifyDeliveryChanged(),
          decoration: _deliveryFieldDecoration(
            label: 'Street / area *',
            hint: 'House / street, area',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.deliveryCityController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          style: _deliveryInputTextStyle,
          cursorColor: AppColors.primary,
          onChanged: (_) => controller.notifyDeliveryChanged(),
          decoration: _deliveryFieldDecoration(label: 'City', hint: 'Optional'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.deliveryPostalController,
          textInputAction: TextInputAction.done,
          style: _deliveryInputTextStyle,
          cursorColor: AppColors.primary,
          onChanged: (_) => controller.notifyDeliveryChanged(),
          decoration: _deliveryFieldDecoration(
            label: 'Postal code',
            hint: 'Optional',
          ),
        ),
      ],
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
                sublabel: controller.total < kCodMaxPkr
                    ? 'Pay when you receive'
                    : 'Only for orders under PKR ${kCodMaxPkr.toStringAsFixed(0)}',
                selected: controller.selectedPayment.value == PaymentMethod.cod,
                onTap: () => controller.selectPayment(PaymentMethod.cod),
              ),
              const SizedBox(height: 12),
              // Bank Transfer — extra 5% off (not available on COD)
              _PaymentTile(
                icon: Icons.account_balance_outlined,
                label: 'Bank Transfer',
                sublabel:
                    'Extra ${kBankTransferExtraDiscountPercent.toStringAsFixed(0)}% off · '
                    'Upload receipt · Not available on COD',
                selected:
                    controller.selectedPayment.value ==
                    PaymentMethod.bankTransfer,
                onTap: () =>
                    controller.selectPayment(PaymentMethod.bankTransfer),
              ),
              if (controller.selectedPayment.value ==
                  PaymentMethod.bankTransfer) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: AppColors.success.withValues(alpha: 0.95),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You always get an extra ${kBankTransferExtraDiscountPercent.toStringAsFixed(0)}% off on bank transfer on top of any discount you already have (welcome, ads, etc.). COD does not include this bonus.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 11,
                            height: 1.4,
                            color: AppColors.textDark.withValues(alpha: 0.78),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
          _bankRow('Bank', 'Meezan Bank'),
          const SizedBox(height: 6),
          _bankRow('Account Name', 'M Umair Siddiqui '),
          const SizedBox(height: 6),
          _bankRow('Account No.', '99520105774580'),
          const SizedBox(height: 6),
          _bankRow('IBAN', 'PK56MEZN0099520105774580'),
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
    return Obx(() {
      final uploaded = controller.receiptUploaded.value;
      final uploading = controller.isUploadingReceipt.value;

      return GestureDetector(
        onTap: uploading ? null : controller.uploadReceipt,
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
                child: uploading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.upload_file_outlined,
                        color: AppColors.secondary,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      uploaded ? 'Receipt Uploaded' : 'Upload Payment Receipt',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      uploaded
                          ? 'Tap to replace screenshot.'
                          : 'Take a screenshot of your transfer and upload it here.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (uploaded)
                IconButton(
                  onPressed: controller.clearReceipt,
                  icon: const Icon(Icons.close),
                  tooltip: 'Remove receipt',
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textDark.withValues(alpha: 0.4),
                ),
            ],
          ),
        ),
      );
    });
  }

  // ── Referral + wallet balance (checkout) ──────────────────────────────────

  Widget _buildReferralAndWalletSection() {
    return Obx(() {
      WalletService.to.balance.value;
      WalletService.to.pendingRewards.value;
      controller.completedOrderCount.value;
      controller.applyWalletBalance.value;

      final showReferral = controller.isFirstOrderForReferralUi;
      final bal = WalletService.to.balance.value;
      final canUseWallet = bal > 0.009 && controller.items.isNotEmpty;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Referral & wallet',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            if (showReferral) ...[
              Text(
                'Referral code (first order only)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.referralCodeController,
                textCapitalization: TextCapitalization.characters,
                style: _deliveryInputTextStyle,
                cursorColor: AppColors.primary,
                onChanged: (_) => controller.scheduleReferralPreviewRefresh(),
                decoration:
                    _deliveryFieldDecoration(
                      label: 'Enter referral code',
                      hint: 'Friend\'s code',
                    ).copyWith(
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.35),
                        fontSize: 14,
                      ),
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'On your first order with a valid code: free delivery for you. '
                'Your friend earns PKR ${kReferralRewardPkr.toStringAsFixed(0)} store credit after '
                'this order is marked Delivered (and paid if required).',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11,
                  color: AppColors.textDark.withValues(alpha: 0.45),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (controller.canUseBirthdayDiscount) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.cake_outlined,
                      color: Colors.pink,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Birthday Month Offer!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.pink.shade700,
                          ),
                        ),
                        Text(
                          'Enjoy 10% OFF on your birthday month.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textDark.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: controller.applyBirthdayDiscount.value,
                      activeColor: Colors.pink,
                      onChanged: (v) => controller.applyBirthdayDiscount.value = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallet balance',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PKR ${bal.toStringAsFixed(0)} available to spend (from referrals & rewards)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.textDark.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.applyWalletBalance.value && canUseWallet,
                  activeColor: AppColors.primary,
                  onChanged: canUseWallet
                      ? (v) {
                          controller.applyWalletBalance.value = v;
                          if (v) {
                            controller.applyMaxWallet();
                          } else {
                            controller.walletAmountController.clear();
                            controller.customWalletAmount.value = 0;
                          }
                        }
                      : null,
                ),
              ],
            ),
            if (controller.applyWalletBalance.value && canUseWallet) ...[
              const SizedBox(height: 12),
              TextField(
                controller: controller.walletAmountController,
                keyboardType: TextInputType.number,
                style: _deliveryInputTextStyle.copyWith(fontSize: 15),
                cursorColor: AppColors.primary,
                onChanged: controller.onWalletAmountChanged,
                decoration: _deliveryFieldDecoration(
                  label: 'Amount to use (PKR)',
                  hint: 'Enter amount',
                ).copyWith(
                  suffixIcon: TextButton(
                    onPressed: controller.applyMaxWallet,
                    child: Text(
                      'MAX',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (!canUseWallet && controller.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  bal <= 0.009
                      ? 'No balance yet — earn from Refer & Earn when friends’ orders complete.'
                      : 'Add items to apply wallet.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11,
                    color: AppColors.textDark.withValues(alpha: 0.4),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // ── Order summary ───────────────────────────────────────────────────────────

  Widget _buildOrderSummary() {
    return Obx(() {
      // Rebuild when cart or store discounts change
      ProductService.to.globalDiscountPercent.value;
      ProductService.to.productsVersion.value;
      DiscountService.to.currentDiscountPercent.value;
      WalletService.to.balance.value;
      controller.applyWalletBalance.value;
      controller.referralPreviewFreeDelivery.value;
      controller.selectedPayment.value;
      final gross = controller.invoiceGrossSubtotal;
      final prodSav = controller.invoiceProductSavingsTotal;
      final globSav = controller.invoiceGlobalSavingsTotal;
      final userSav = controller.userDiscountAmount;
      final userPct = controller.userDiscountPercent;
      final bankSav = controller.bankTransferDiscountAmount;
      final hasSplit =
          prodSav > 0.009 ||
          globSav > 0.009 ||
          userSav > 0.009 ||
          bankSav > 0.009;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order summary',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            if (hasSplit) ...[
              _SummaryRow(label: 'Items (list price)', value: gross),
              if (prodSav > 0.009) ...[
                const SizedBox(height: 8),
                _SummaryDiscountRow(label: 'Product discounts', value: prodSav),
              ],
              if (globSav > 0.009) ...[
                const SizedBox(height: 8),
                _SummaryDiscountRow(label: 'Store discount', value: globSav),
              ],
              if (userSav > 0.009) ...[
                const SizedBox(height: 8),
                _SummaryDiscountRow(
                  label: 'Your discount (${userPct.toStringAsFixed(0)}%)',
                  value: userSav,
                ),
              ],
              if (bankSav > 0.009) ...[
                const SizedBox(height: 8),
                _SummaryDiscountRow(
                  label:
                      'Bank transfer only (${kBankTransferExtraDiscountPercent.toStringAsFixed(0)}%)',
                  value: bankSav,
                ),
              ],
              const Divider(height: 20),
            ] else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryRow(label: 'Subtotal', value: controller.subtotal),
                  if (bankSav > 0.009) ...[
                    const SizedBox(height: 8),
                    _SummaryDiscountRow(
                      label:
                          'Bank transfer only (${kBankTransferExtraDiscountPercent.toStringAsFixed(0)}%)',
                      value: bankSav,
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 4),
            if (controller.referralPreviewFreeDelivery.value) ...[
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: AppColors.success.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Delivery — waived with referral (first order)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (controller.walletAppliedAmount > 0.009) ...[
              _SummaryRow(
                label: 'Merchandise total',
                value: controller.merchandiseTotal,
              ),
              const SizedBox(height: 8),
              _SummaryDiscountRow(
                label: 'Wallet applied',
                value: controller.walletAppliedAmount,
              ),
              const SizedBox(height: 8),
            ],
            _SummaryRow(
              label: controller.walletAppliedAmount > 0.009
                  ? 'Amount to pay'
                  : 'Total',
              value: controller.payableTotal,
              isTotal: true,
            ),
          ],
        ),
      );
    });
  }

  // ── Bottom checkout bar ─────────────────────────────────────────────────────

  Widget _buildCheckoutBar() {
    return Obx(() {
      // Subscriptions — keep so the bar rebuilds when cart, auth, or fields change.
      controller.items.length;
      controller.deliveryInputVersion.value;
      controller.selectedPayment.value;
      controller.receiptUploaded.value;
      controller.receiptUrl.value;
      controller.isPlacing.value;
      AuthService.to.currentUser.value;
      DiscountService.to.currentDiscountPercent.value;
      ProductService.to.productsVersion.value;
      WalletService.to.balance.value;
      controller.applyWalletBalance.value;

      final hasItems = controller.items.isNotEmpty;
      final loggedIn = AuthService.to.currentUser.value != null;
      final phoneOk = controller.deliveryPhoneController.text.trim().isNotEmpty;
      final streetOk = controller.deliveryStreetController.text
          .trim()
          .isNotEmpty;
      final deliveryOk = phoneOk && streetOk;
      final isBankTransfer =
          controller.selectedPayment.value == PaymentMethod.bankTransfer;
      final receiptReady =
          controller.receiptUploaded.value &&
          controller.receiptUrl.value.trim().isNotEmpty;
      final isPlacing = controller.isPlacing.value;
      final canPlace = controller.isReadyToPlaceOrder;
      final label = isBankTransfer ? 'Confirm Order' : 'Place Order';
      final showEnabledStyle = canPlace || isPlacing;

      String? hint;
      if (!hasItems) {
        hint = 'Add products to your cart first.';
      } else if (!loggedIn) {
        hint = 'Sign in to place your order.';
      } else if (!deliveryOk) {
        hint = 'Enter phone number and street address.';
      } else if (isBankTransfer && !receiptReady) {
        hint = 'Upload your bank transfer receipt to continue.';
      } else if (controller.selectedPayment.value == PaymentMethod.cod &&
          controller.payableTotal >= kCodMaxPkr) {
        hint =
            'COD is only under PKR ${kCodMaxPkr.toStringAsFixed(0)}. Use bank transfer or reduce total.';
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
            if (hint != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppColors.textDark.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        hint,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.textDark.withValues(alpha: 0.5),
                        ),
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
                  gradient: showEnabledStyle
                      ? const LinearGradient(
                          colors: [AppColors.secondary, AppColors.primary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: showEnabledStyle
                      ? null
                      : AppColors.textDark.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: showEnabledStyle
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
                  child: isPlacing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
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
    return Obx(() {
      ProductService.to.globalDiscountPercent.value;
      ProductService.to.productsVersion.value;
      final product = ProductService.to.findById(item.id);
      ProductPriceBreakdown? bd;
      double? listLine;
      if (product != null) {
        bd = ProductService.to.breakdown(product);
        listLine = product.price * item.qty.value;
      }

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
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: AppColors.primary,
                size: 32,
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
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product?.unitSize != null && product!.unitSize!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Size: ${product.unitSize}${product.unitSize!.toLowerCase().contains('ml') ? '' : 'ml'}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'PKR ${item.unitPrice.toStringAsFixed(0)} / unit',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.55),
                    ),
                  ),
                  if (bd != null &&
                      (bd.productDiscountPercent > 0 ||
                          bd.globalDiscountPercent > 0)) ...[
                    const SizedBox(height: 4),
                    if (listLine != null)
                      Text(
                        'Was PKR ${listLine.toStringAsFixed(0)} (list × qty)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 10,
                          color: AppColors.textDark.withValues(alpha: 0.4),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (bd.productDiscountPercent > 0)
                          _MiniChip(
                            label:
                                '−${bd.productDiscountPercent.toStringAsFixed(0)}% product',
                          ),
                        if (bd.globalDiscountPercent > 0)
                          _MiniChip(
                            label:
                                '−${bd.globalDiscountPercent.toStringAsFixed(0)}% store',
                          ),
                      ],
                    ),
                  ],
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
                Text(
                  'PKR ${(item.unitPrice * item.qty.value).toStringAsFixed(0)}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _MiniChip extends StatelessWidget {
  final String label;

  const _MiniChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.success,
        ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
              child: Icon(
                icon,
                color: selected ? AppColors.primary : Colors.grey.shade500,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  if (sublabel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      sublabel,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textDark.withValues(alpha: 0.55),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary rows ──────────────────────────────────────────────────────────────

class _SummaryDiscountRow extends StatelessWidget {
  final String label;
  final double value;

  const _SummaryDiscountRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.success.withValues(alpha: 0.95),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        Text(
          '− PKR ${value.toStringAsFixed(0)}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

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
                  color: AppColors.primary,
                  fontSize: 18,
                )
              : AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.7),
                ),
        ),
      ],
    );
  }
}
