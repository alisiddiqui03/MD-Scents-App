class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String role; // 'admin' or 'user'

  const AppUser({
    required this.uid,
    required this.role,
    this.email,
    this.displayName,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(String uid, Map<String, dynamic>? data) {
    final map = data ?? <String, dynamic>{};
    return AppUser(
      uid: uid,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      role: (map['role'] as String?) ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
    };
  }
}

