import 'package:get/get.dart';

import '../../../../app/data/models/order.dart';
import '../../../../app/services/user_order_stream_service.dart';

/// Filters and UI state for My Orders; order list + Firestore stream live in
/// [UserOrderStreamService] so cancellations notify on any tab / route.
class UserOrdersController extends GetxController {
  UserOrderStreamService get _stream => UserOrderStreamService.to;

  final statusFilter = Rxn<OrderStatus>();

  RxList<Order> get orders => _stream.orders;
  RxBool get isLoading => _stream.isLoading;

  Future<void> refreshOrders() => _stream.refreshOrders();

  void setStatusFilter(OrderStatus? status) {
    statusFilter.value = status;
  }

  List<Order> get displayOrders {
    final _ = orders.length;
    final filter = statusFilter.value;
    final list = List<Order>.from(orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (filter == null) return list;
    return list.where((o) => o.status == filter).toList();
  }

  bool get hasOrders => orders.isNotEmpty;
}
