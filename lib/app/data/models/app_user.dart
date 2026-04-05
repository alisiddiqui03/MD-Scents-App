class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String role; // 'admin' or 'user'

  /// Public share code (unique; stored in Firestore + `referralCodes/{code}`).
  final String? referralCode;

  /// Referrer uid after a valid referral on the user's first order (client + rules).
  final String? referredBy;

  const AppUser({
    required this.uid,
    required this.role,
    this.email,
    this.displayName,
    this.referralCode,
    this.referredBy,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(String uid, Map<String, dynamic>? data) {
    final map = data ?? <String, dynamic>{};
    return AppUser(
      uid: uid,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      role: (map['role'] as String?) ?? 'user',
      referralCode: map['referralCode'] as String?,
      referredBy: map['referredBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'email': email,
      'displayName': displayName,
      'role': role,
    };
    if (referralCode != null) m['referralCode'] = referralCode;
    if (referredBy != null) m['referredBy'] = referredBy;
    return m;
  }
}

