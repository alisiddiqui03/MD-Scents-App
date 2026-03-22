import 'package:get/get.dart';

import '../../../../app/services/order_service.dart';
import '../../../../app/services/product_service.dart';

class AdminDashboardController extends GetxController {
  final OrderService _orderService = OrderService.to;
  final ProductService _productService = ProductService.to;

  double get totalSales => _orderService.totalRevenue;
  int get totalOrders => _orderService.totalOrders;
  int get totalProducts => _productService.getAllProducts().length;
  int get pendingOrders => _orderService.pendingCount;
  int get shippedOrders => _orderService.shippedCount;
  int get deliveredOrders => _orderService.deliveredCount;
  int get unpaidOrders => _orderService.unpaidCount;

  int get codOrders => _orderService.codOrdersCount;
  int get bankOrders => _orderService.bankTransferOrdersCount;
  int get paidOrders => _orderService.paidOrdersCount;

  int get lowStockCount => _productService.lowStockProductCount;

  /// PKR per day for the last 7 days (index 0 = oldest day).
  List<double> get revenueLast7Days {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    final result = List<double>.filled(7, 0);
    for (final o in _orderService.orders) {
      final d = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
      if (d.isBefore(start)) continue;
      final diff = d.difference(start).inDays;
      if (diff >= 0 && diff < 7) {
        result[diff] += o.total;
      }
    }
    return result;
  }

  /// Short labels for the 7 days (e.g. 10/3).
  List<String> get last7DayLabels {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    return List.generate(7, (i) {
      final d = start.add(Duration(days: i));
      return '${d.day}/${d.month}';
    });
  }
}
