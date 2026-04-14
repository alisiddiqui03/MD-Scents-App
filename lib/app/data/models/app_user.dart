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
  });

  bool get isAdmin => role == 'admin';

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
    };
    if (referralCode != null) m['referralCode'] = referralCode;
    if (referredBy != null) m['referredBy'] = referredBy;
    return m;
  }
}

