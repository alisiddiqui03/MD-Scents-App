import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, packed, shipped, delivered, cancelled }

class OrderItem {
  /// Firestore product document id (required for inventory + restock).
  final String? productId;
  final String productName;
  final int quantity;
  final double price;

  const OrderItem({
    this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] as String?,
      productName: data['productName'] as String? ?? 'Unknown',
      quantity: data['quantity'] as int? ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
    if (productId != null) m['productId'] = productId;
    return m;
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

  /// PKR merchandise before wallet deduction (after product/store discounts).
  final double merchandiseTotal;

  /// Store credit applied to this order (PKR).
  final double walletAppliedAmount;

  /// Extra PKR off for bank transfer only (5% of post–user-discount subtotal).
  final double bankTransferDiscountAmount;

  /// Code string entered at checkout (audit).
  final String? referralCodeEntered;

  /// Device fingerprint for basic fraud hints (optional).
  final String? referralDeviceId;

  /// Referrer's user id when a valid referral applies on this order.
  final String? referredBy;

  /// True when a referral code was supplied for this order.
  final bool referralUsed;

  /// True when referral rules accepted the code (first order, valid, not self).
  final bool referralApplied;

  /// True when this is the customer's first ever order in the app.
  final bool isFirstOrderForUser;

  /// Referrer's PKR 500 is due when order is delivered (admin).
  final bool referralRewardPending;

  /// True after referrer wallet was credited (idempotent guard).
  final bool referralRewardGranted;

  /// Doc id under [referrerUid]/referrals/{id}.
  final String? referralRecordId;

  /// Referred user perk: show free delivery in UI / ops.
  final bool referralFreeDelivery;

  /// Legacy: older Cloud Function naming (read-only mapping in [fromMap]).
  final bool referralServerProcessed;

  final String? firestorePath;

  final String deliveryPhone;
  final String deliveryStreet;
  final String deliveryCity;
  final String deliveryPostalCode;

  final String? cancellationReason;
  final DateTime? cancelledAt;
  final bool cancellationUnreadForUser;

  /// True when the user has successfully submitted a picture review for this order.
  final bool reviewSubmitted;

  /// The exact time the admin marked the order as delivered.
  final DateTime? deliveredAt;

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
    this.merchandiseTotal = 0,
    this.walletAppliedAmount = 0,
    this.bankTransferDiscountAmount = 0,
    this.referralCodeEntered,
    this.referralDeviceId,
    this.referredBy,
    this.referralUsed = false,
    this.referralApplied = false,
    this.isFirstOrderForUser = false,
    this.referralRewardPending = false,
    this.referralRewardGranted = false,
    this.referralRecordId,
    this.referralFreeDelivery = false,
    this.referralServerProcessed = false,
    this.firestorePath,
    this.deliveryPhone = '',
    this.deliveryStreet = '',
    this.deliveryCity = '',
    this.deliveryPostalCode = '',
    this.cancellationReason,
    this.cancelledAt,
    this.cancellationUnreadForUser = false,
    this.reviewSubmitted = false,
    this.deliveredAt,
  });

  /// The exact time when the review window expires (7 days after delivery).
  DateTime? get reviewPeriodEndDate {
    if (deliveredAt == null) return null;
    return deliveredAt!.add(const Duration(days: 7));
  }

  String get deliverySummaryLine {
    final parts = <String>[
      if (deliveryStreet.trim().isNotEmpty) deliveryStreet.trim(),
      if (deliveryCity.trim().isNotEmpty) deliveryCity.trim(),
      if (deliveryPostalCode.trim().isNotEmpty) deliveryPostalCode.trim(),
    ];
    return parts.join(', ');
  }

  /// Human-readable referral reward state for admin.
  String get referralStatusLabel {
    if (!referralApplied || referredBy == null) return '—';
    if (referralRewardGranted) return 'Reward paid';
    if (referralRewardPending) return 'Pending (deliver order)';
    return '—';
  }

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
      merchandiseTotal: merchandiseTotal,
      walletAppliedAmount: walletAppliedAmount,
      bankTransferDiscountAmount: bankTransferDiscountAmount,
      referralCodeEntered: referralCodeEntered,
      referralDeviceId: referralDeviceId,
      referredBy: referredBy,
      referralUsed: referralUsed,
      referralApplied: referralApplied,
      isFirstOrderForUser: isFirstOrderForUser,
      referralRewardPending: referralRewardPending,
      referralRewardGranted: referralRewardGranted,
      referralRecordId: referralRecordId,
      referralFreeDelivery: referralFreeDelivery,
      referralServerProcessed: referralServerProcessed,
      firestorePath: firestorePath,
      deliveryPhone: deliveryPhone,
      deliveryStreet: deliveryStreet,
      deliveryCity: deliveryCity,
      deliveryPostalCode: deliveryPostalCode,
      cancellationReason: cancellationReason,
      cancelledAt: cancelledAt,
      cancellationUnreadForUser: cancellationUnreadForUser,
      reviewSubmitted: reviewSubmitted,
      deliveredAt: deliveredAt,
    );
  }

  factory Order.fromMap(
    String id,
    Map<String, dynamic> data, {
    String? firestorePath,
  }) {
    final itemsData = (data['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromMap)
        .toList();

    final cancelledTs = data['cancelledAt'];
    DateTime? cancelledAt;
    if (cancelledTs is Timestamp) cancelledAt = cancelledTs.toDate();

    final referred =
        data['referredBy'] as String? ?? data['referralRewardReferrerUid'] as String?;
    final rewardGranted = data['referralRewardGranted'] as bool? ??
        data['referralRewardActivated'] as bool? ??
        false;

    return Order(
      id: id,
      userId: data['userId'] as String?,
      customerName: data['customerName'] as String? ?? '',
      customerEmail: data['customerEmail'] as String? ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      status: _statusFromString(data['status'] as String?),
      isCod: data['isCod'] as bool? ?? false,
      isPaid: data['isPaid'] as bool? ?? false,
      paymentReceiptUrl: data['paymentReceiptUrl'] as String?,
      items: itemsData,
      merchandiseTotal: (data['merchandiseTotal'] as num?)?.toDouble() ??
          (data['total'] as num?)?.toDouble() ??
          0,
      walletAppliedAmount:
          (data['walletAppliedAmount'] as num?)?.toDouble() ?? 0,
      bankTransferDiscountAmount:
          (data['bankTransferDiscountAmount'] as num?)?.toDouble() ?? 0,
      referralCodeEntered: data['referralCodeEntered'] as String?,
      referralDeviceId: data['referralDeviceId'] as String?,
      referredBy: referred,
      referralUsed: data['referralUsed'] as bool? ?? false,
      referralApplied: data['referralApplied'] as bool? ??
          (referred != null && referred.isNotEmpty),
      isFirstOrderForUser: data['isFirstOrderForUser'] as bool? ?? false,
      referralRewardPending: data['referralRewardPending'] as bool? ??
          (referred != null && referred.isNotEmpty && !rewardGranted),
      referralRewardGranted: rewardGranted,
      referralRecordId: data['referralRecordId'] as String? ??
          data['referralRewardDocId'] as String?,
      referralFreeDelivery: data['referralFreeDelivery'] as bool? ?? false,
      referralServerProcessed: data['referralServerProcessed'] as bool? ?? false,
      firestorePath: firestorePath,
      deliveryPhone: data['deliveryPhone'] as String? ?? '',
      deliveryStreet: data['deliveryStreet'] as String? ?? '',
      deliveryCity: data['deliveryCity'] as String? ?? '',
      deliveryPostalCode: data['deliveryPostalCode'] as String? ?? '',
      cancellationReason: data['cancellationReason'] as String?,
      cancelledAt: cancelledAt,
      cancellationUnreadForUser:
          data['cancellationUnreadForUser'] as bool? ?? false,
      reviewSubmitted: data['reviewSubmitted'] as bool? ?? false,
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
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
      'deliveryPhone': deliveryPhone,
      'deliveryStreet': deliveryStreet,
      'deliveryCity': deliveryCity,
      'deliveryPostalCode': deliveryPostalCode,
      'cancellationUnreadForUser': cancellationUnreadForUser,
      'merchandiseTotal': merchandiseTotal,
      'walletAppliedAmount': walletAppliedAmount,
      'bankTransferDiscountAmount': bankTransferDiscountAmount,
      'referralUsed': referralUsed,
      'referralApplied': referralApplied,
      'isFirstOrderForUser': isFirstOrderForUser,
      'referralRewardPending': referralRewardPending,
      'referralRewardGranted': referralRewardGranted,
      'referralFreeDelivery': referralFreeDelivery,
      'reviewSubmitted': reviewSubmitted,
    };
    if (userId != null) map['userId'] = userId;
    if (referralCodeEntered != null) {
      map['referralCodeEntered'] = referralCodeEntered;
    }
    if (referralDeviceId != null) map['referralDeviceId'] = referralDeviceId;
    if (referredBy != null) map['referredBy'] = referredBy;
    if (referralRecordId != null) map['referralRecordId'] = referralRecordId;
    if (cancellationReason != null) {
      map['cancellationReason'] = cancellationReason;
    }
    if (cancelledAt != null) {
      map['cancelledAt'] = Timestamp.fromDate(cancelledAt!);
    }
    if (deliveredAt != null) {
      map['deliveredAt'] = Timestamp.fromDate(deliveredAt!);
    }
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
