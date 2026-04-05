import 'package:firebase_auth/firebase_auth.dart';

/// Thrown when Google sign-in hits [FirebaseAuthException] with code
/// `account-exists-with-different-credential`. The UI should collect the
/// existing email/password and call [AuthService.linkGoogleAfterEmailPassword].
class GoogleAccountNeedsPasswordException implements Exception {
  GoogleAccountNeedsPasswordException({
    required this.email,
    required this.googleCredential,
  });

  final String email;
  final OAuthCredential googleCredential;

  @override
  String toString() =>
      'GoogleAccountNeedsPasswordException(email: $email)';
}
