import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, packed, shipped, delivered, cancelled }

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  const OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productName: data['productName'] as String? ?? 'Unknown',
      quantity: data['quantity'] as int? ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String? userId;
  final String customerName;
  final String customerEmail;
  final double total;
  final DateTime createdAt;
  final OrderStatus status;
  final bool isCod;
  final bool isPaid;
  final String? paymentReceiptUrl;
  final List<OrderItem> items;
  /// Full Firestore path (users/uid/orders/docId) for admin updateStatus
  final String? firestorePath;

  const Order({
    required this.id,
    this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.total,
    required this.createdAt,
    required this.status,
    required this.isCod,
    required this.isPaid,
    this.paymentReceiptUrl,
    required this.items,
    this.firestorePath,
  });

  Order copyWith({
    OrderStatus? status,
    bool? isPaid,
    String? paymentReceiptUrl,
  }) {
    return Order(
      id: id,
      userId: userId,
      customerName: customerName,
      customerEmail: customerEmail,
      total: total,
      createdAt: createdAt,
      status: status ?? this.status,
      isCod: isCod,
      isPaid: isPaid ?? this.isPaid,
      paymentReceiptUrl: paymentReceiptUrl ?? this.paymentReceiptUrl,
      items: items,
      firestorePath: firestorePath,
    );
  }

  factory Order.fromMap(String id, Map<String, dynamic> data,
      {String? firestorePath}) {
    final itemsData = (data['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromMap)
        .toList();

    return Order(
      id: id,
      userId: data['userId'] as String?,
      customerName: data['customerName'] as String? ?? '',
      customerEmail: data['customerEmail'] as String? ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      status: _statusFromString(data['status'] as String?),
      isCod: data['isCod'] as bool? ?? false,
      isPaid: data['isPaid'] as bool? ?? false,
      paymentReceiptUrl: data['paymentReceiptUrl'] as String?,
      items: itemsData,
      firestorePath: firestorePath,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'customerName': customerName,
      'customerEmail': customerEmail,
      'total': total,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'isCod': isCod,
      'isPaid': isPaid,
      'paymentReceiptUrl': paymentReceiptUrl,
      'items': items.map((e) => e.toMap()).toList(),
    };
    if (userId != null) map['userId'] = userId;
    return map;
  }
}

OrderStatus _statusFromString(String? value) {
  switch (value) {
    case 'pending':
      return OrderStatus.pending;
    case 'packed':
      return OrderStatus.packed;
    case 'shipped':
      return OrderStatus.shipped;
    case 'delivered':
      return OrderStatus.delivered;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}

