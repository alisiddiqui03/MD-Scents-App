import 'package:cloud_firestore/cloud_firestore.dart';

class PointHistoryItem {
  final String id;
  final String type; 
  final int points; 
  final DateTime createdAt;
  final String? referenceId; 

  PointHistoryItem({
    required this.id,
    required this.type,
    required this.points,
    required this.createdAt,
    this.referenceId,
  });

  factory PointHistoryItem.fromMap(String id, Map<String, dynamic> map) {
    return PointHistoryItem(
      id: id,
      type: map['type'] as String? ?? 'unknown',
      points: (map['points'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      referenceId: map['referenceId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
      'referenceId': referenceId,
    };
  }

  String get title {
    switch (type) {
      case 'birthday':
        return 'Birthday Reward';
      case 'review':
        return 'Review Reward';
      case 'redeem':
        return 'Points Redeemed';
      case 'order':
        return 'Order Points';
      case 'milestone':
        return 'Milestone Reward';
      case 'vip_high_roller':
        return 'VIP High Roller Bonus';
      default:
        return 'Reward';
    }
  }
}
