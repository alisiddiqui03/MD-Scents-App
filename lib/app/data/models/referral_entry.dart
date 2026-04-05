import 'package:cloud_firestore/cloud_firestore.dart';

enum ReferralStatus { pending, completed }

class ReferralEntry {
  final String id;
  final String referredUserId;
  final String orderId;
  final ReferralStatus status;
  final double rewardAmount;
  final DateTime? createdAt;
  final DateTime? completedAt;

  /// Denormalized at checkout (invited friend).
  final String? referredUserName;
  final String? referredUserEmail;

  const ReferralEntry({
    required this.id,
    required this.referredUserId,
    required this.orderId,
    required this.status,
    required this.rewardAmount,
    this.createdAt,
    this.completedAt,
    this.referredUserName,
    this.referredUserEmail,
  });

  factory ReferralEntry.fromDoc(
    String id,
    Map<String, dynamic> data,
  ) {
    final ts = data['createdAt'];
    DateTime? created;
    if (ts is Timestamp) created = ts.toDate();
    final ct = data['completedAt'];
    DateTime? completed;
    if (ct is Timestamp) completed = ct.toDate();

    ReferralStatus st;
    switch (data['status'] as String? ?? '') {
      case 'completed':
        st = ReferralStatus.completed;
        break;
      default:
        st = ReferralStatus.pending;
    }

    return ReferralEntry(
      id: id,
      referredUserId: data['referredUserId'] as String? ?? '',
      orderId: data['orderId'] as String? ?? '',
      status: st,
      rewardAmount: (data['rewardAmount'] as num?)?.toDouble() ?? 0,
      createdAt: created,
      completedAt: completed,
      referredUserName: data['referredUserName'] as String?,
      referredUserEmail: data['referredUserEmail'] as String?,
    );
  }
}
