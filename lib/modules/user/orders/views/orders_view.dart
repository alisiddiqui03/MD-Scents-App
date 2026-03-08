import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

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
          'MY ORDERS',
          style: AppTextStyles.titleLarge.copyWith(letterSpacing: 1),
        ),
        centerTitle: true,
      ),
      body: _mockOrders.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _mockOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _OrderCard(order: _mockOrders[i]),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 64, color: AppColors.textDark.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('No orders yet',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.4),
              )),
          const SizedBox(height: 8),
          Text('Your order history will appear here.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDark.withValues(alpha: 0.35),
              )),
        ],
      ),
    );
  }
}

// ── Mock data (will be replaced with Firestore) ───────────────────────────────

class _OrderData {
  final String orderId;
  final String date;
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final List<String> items;
  final String total;

  const _OrderData({
    required this.orderId,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.items,
    required this.total,
  });
}

const _mockOrders = [
  _OrderData(
    orderId: '#MD-20241',
    date: '28 Feb 2025',
    status: 'Delivered',
    statusColor: AppColors.success,
    statusIcon: Icons.check_circle_outline,
    items: ['Oud Al Layl × 1', 'Rose Elixir × 2'],
    total: 'PKR 8,500',
  ),
  _OrderData(
    orderId: '#MD-20238',
    date: '20 Feb 2025',
    status: 'Shipped',
    statusColor: AppColors.secondary,
    statusIcon: Icons.local_shipping_outlined,
    items: ['Midnight Musk × 1'],
    total: 'PKR 3,200',
  ),
  _OrderData(
    orderId: '#MD-20231',
    date: '10 Feb 2025',
    status: 'Processing',
    statusColor: AppColors.accent,
    statusIcon: Icons.hourglass_top_rounded,
    items: ['Amber Noir × 1', 'Cedar Wood × 1'],
    total: 'PKR 6,800',
  ),
];

// ── Order card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final _OrderData order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // Header row: order ID + status
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: order.statusColor.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Row(
                  children: [
                    Icon(order.statusIcon,
                        color: order.statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      order.status,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: order.statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items + date + total
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop_outlined,
                            size: 13,
                            color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(item,
                            style: AppTextStyles.bodyMedium
                                .copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey.shade100),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.date,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            AppColors.textDark.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      order.total,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
