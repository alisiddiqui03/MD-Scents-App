import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String role; // 'admin' or 'user'
  final DateTime? birthday;
  final bool birthdayRewardGiven;
  final int? birthdayDiscountUsedYear;
  final int points;
  final DateTime? milestoneStartDate;
  final int milestoneOrderCount;
  final DateTime? lastMilestoneOrderTime;

  final bool isVip;
  final String? vipType; // "monthly" or "yearly"
  final DateTime? vipStartDate;
  final DateTime? vipEndDate;
  final double vipHighRollerSpent;
  final bool vipHighRollerRewardGiven;

  /// Public share code (unique; stored in Firestore + `referralCodes/{code}`).
  final String? referralCode;

  /// Referrer uid after a valid referral on the user's first order (client + rules).
  final String? referredBy;

  const AppUser({
    required this.uid,
    required this.role,
    this.birthday,
    this.birthdayRewardGiven = false,
    this.birthdayDiscountUsedYear,
    this.email,
    this.displayName,
    this.referralCode,
    this.referredBy,
    this.points = 0,
    this.milestoneStartDate,
    this.milestoneOrderCount = 0,
    this.lastMilestoneOrderTime,
    this.isVip = false,
    this.vipType,
    this.vipStartDate,
    this.vipEndDate,
    this.vipHighRollerSpent = 0.0,
    this.vipHighRollerRewardGiven = false,
  });

  bool get isAdmin => role == 'admin';

  /// Single source of truth: VIP is active only with a valid future end date.
  bool get isVipActive {
    return isVip == true &&
        vipEndDate != null &&
        vipEndDate!.isAfter(DateTime.now());
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic>? data) {
    final map = data ?? <String, dynamic>{};
    return AppUser(
      uid: uid,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      role: (map['role'] as String?) ?? 'user',
      birthday: map['birthday'] != null
          ? (map['birthday'] as Timestamp).toDate()
          : null,
      birthdayRewardGiven: map['birthdayRewardGiven'] as bool? ?? false,
      birthdayDiscountUsedYear: map['birthdayDiscountUsedYear'] as int?,
      referralCode: map['referralCode'] as String?,
      referredBy: map['referredBy'] as String?,
      points: (map['points'] as num?)?.toInt() ?? 0,
      milestoneStartDate: (map['milestoneStartDate'] as Timestamp?)?.toDate(),
      milestoneOrderCount: (map['milestoneOrderCount'] as num?)?.toInt() ?? 0,
      lastMilestoneOrderTime:
          (map['lastMilestoneOrderTime'] as Timestamp?)?.toDate(),
      isVip: map['isVip'] as bool? ?? false,
      vipType: map['vipType'] as String?,
      vipStartDate: (map['vipStartDate'] as Timestamp?)?.toDate(),
      vipEndDate: (map['vipEndDate'] as Timestamp?)?.toDate(),
      vipHighRollerSpent:
          (map['vipHighRollerSpent'] as num?)?.toDouble() ?? 0.0,
      vipHighRollerRewardGiven:
          map['vipHighRollerRewardGiven'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'email': email,
      'displayName': displayName,
      'role': role,
      'birthday': birthday != null ? Timestamp.fromDate(birthday!) : null,
      'birthdayRewardGiven': birthdayRewardGiven,
      'birthdayDiscountUsedYear': birthdayDiscountUsedYear,
      'points': points,
      'milestoneStartDate':
          milestoneStartDate != null ? Timestamp.fromDate(milestoneStartDate!) : null,
      'milestoneOrderCount': milestoneOrderCount,
      'lastMilestoneOrderTime': lastMilestoneOrderTime != null
          ? Timestamp.fromDate(lastMilestoneOrderTime!)
          : null,
      'isVip': isVip,
      'vipType': vipType,
      'vipStartDate': vipStartDate != null ? Timestamp.fromDate(vipStartDate!) : null,
      'vipEndDate': vipEndDate != null ? Timestamp.fromDate(vipEndDate!) : null,
      'vipHighRollerSpent': vipHighRollerSpent,
      'vipHighRollerRewardGiven': vipHighRollerRewardGiven,
    };
    if (referralCode != null) m['referralCode'] = referralCode;
    if (referredBy != null) m['referredBy'] = referredBy;
    return m;
  }
}

