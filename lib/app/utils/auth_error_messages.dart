import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

/// Short, user-readable copy — avoids raw [FirebaseAuthException] / [PlatformException] `toString()` noise.
String userFacingAuthError(Object error) {
  if (error is FirebaseAuthException) {
    return _firebaseAuthMessage(error);
  }
  if (error is PlatformException) {
    return _platformMessage(error);
  }

  var s = error.toString();
  if (s.startsWith('Exception: ')) {
    s = s.substring('Exception: '.length);
  }
  // Common nested Google Play services text
  if (s.contains('ApiException: 10') || s.contains('10:')) {
    return _sha1Hint;
  }
  if (s.contains('ApiException: 7') || s.contains('NETWORK_ERROR')) {
    return 'Network error. Check your connection and try again.';
  }
  if (s.contains('invalid-credential') ||
      s.contains('INVALID_CREDENTIAL') ||
      s.toLowerCase().contains('malformed')) {
    return _googleConfigHint;
  }
  if (s.contains('PlatformException')) {
    return 'Google sign-in failed. Check Firebase Google sign-in setup and app SHA-1 fingerprints.';
  }
  // Last resort: single line, no huge type dumps
  if (s.length > 200) {
    return 'Something went wrong. Please try again.';
  }
  return s;
}

String _firebaseAuthMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'invalid-custom-token':
      final m = e.message?.trim();
      if (m != null && m.isNotEmpty) {
        return m;
      }
      return _googleConfigHint;
    case 'google-sign-in-aborted':
      return e.message ?? 'Sign-in was cancelled.';
    case 'account-exists-with-different-credential':
      return e.message ??
          'This email is already registered with another sign-in method. Use email and password to sign in.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'operation-not-allowed':
      return 'Google sign-in is not enabled for this app. Enable it in Firebase Authentication.';
    default:
      return e.message ?? e.code;
  }
}

String _platformMessage(PlatformException e) {
  final d = '${e.message ?? ''} ${e.details ?? ''}';
  if (d.contains('ApiException: 10') || d.contains(': 10,')) {
    return _sha1Hint;
  }
  if (d.contains('ApiException: 7')) {
    return 'Network error. Check your connection and try again.';
  }
  if (d.contains('12500') || d.contains('SIGN_IN_FAILED')) {
    return 'Google sign-in was cancelled or failed. Try again or check Google Play services.';
  }
  return 'Google sign-in failed. Check Firebase Google provider, SHA-1, and Web client ID.';
}

const String _sha1Hint =
    'App signing: add your Android SHA-1 (and SHA-256) in Firebase Project settings '
    'for this app, then download a fresh google-services.json.';

const String _googleConfigHint =
    'Google sign-in is not fully configured. In Firebase: enable the Google provider, '
    'add SHA-1 fingerprints, set the Web client ID in google_auth_config.dart if needed, '
    'then try again.';
