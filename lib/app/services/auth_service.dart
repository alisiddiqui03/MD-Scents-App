import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/google_auth_config.dart';
import '../data/models/app_user.dart';

class AuthService extends GetxService {
  AuthService();

  static AuthService get to => Get.find<AuthService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _googleSignInClient {
    _googleSignIn ??= GoogleSignIn(
      scopes: const <String>['email', 'profile'],
      serverClientId: kGoogleOAuthWebClientId.isEmpty
          ? null
          : kGoogleOAuthWebClientId,
    );
    return _googleSignIn!;
  }

  final Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<AppUser> currentUser = Rxn<AppUser>();

  bool get isLoggedIn => firebaseUser.value != null;
  bool get isAdmin => currentUser.value?.isAdmin ?? false;

  Future<AuthService> init() async {
    firebaseUser.bindStream(_auth.authStateChanges());
    ever<User?>(firebaseUser, _onFirebaseUserChanged);

    final user = _auth.currentUser;
    if (user != null) {
      await _loadUserProfile(user);
    }

    return this;
  }

  Future<void> _onFirebaseUserChanged(User? user) async {
    if (user == null) {
      currentUser.value = null;
      return;
    }
    await _loadUserProfile(user);
  }

  Future<void> _loadUserProfile(User user) async {
    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get(const GetOptions(source: Source.serverAndCache));

    if (doc.exists) {
      currentUser.value = AppUser.fromMap(user.uid, doc.data());
    } else {
      final fallback = AppUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        role: 'user',
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(fallback.toMap(), SetOptions(merge: true));
      currentUser.value = fallback;
    }
  }

  /// Temporary helper to allow navigating the app without real Firebase login.
  Future<void> debugSetMockUser({
    required String email,
    bool asAdmin = false,
  }) async {
    final mockUser = AppUser(
      uid: 'debug-${asAdmin ? 'admin' : 'user'}',
      email: email,
      displayName: asAdmin ? 'Debug Admin' : 'Debug User',
      role: asAdmin ? 'admin' : 'user',
    );
    currentUser.value = mockUser;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _loadUserProfile(credential.user!);
    return credential;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
    String role = 'user',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;

    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
    }

    final profile = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: displayName ?? user.displayName,
      role: role,
    );
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(profile.toMap(), SetOptions(merge: true));
    currentUser.value = profile;
    return credential;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
    } catch (_) {
      // Ignore if Google Sign-In was never used or plugin state is stale.
    }
    await _auth.signOut();
    currentUser.value = null;
    firebaseUser.value = null;
  }

  /// Sends Firebase password-reset email (same for every role: user / admin).
  /// User opens link from email → sets new password → signs in with email/password.
  ///
  /// Configure in Firebase Console:
  /// - Authentication → Templates → Password reset (email copy & sender)
  /// - Authentication → Settings → Authorized domains (your domain / localhost)
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await _googleSignInClient.signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-aborted',
        message: 'Google sign-in was cancelled by the user.',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message:
            'Google did not return an ID token. Enable Google sign-in in Firebase, '
            'add your app SHA-1, re-download google-services.json, and set '
            'kGoogleOAuthWebClientId in lib/app/config/google_auth_config.dart '
            '(Web client ID from Firebase → Authentication → Google).',
      );
    }

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final credentialResult = await _auth.signInWithCredential(credential);
      await _loadUserProfile(credentialResult.user!);
      return credentialResult;
    } on FirebaseAuthException catch (e) {
      // Check if account already exists with different credential
      if (e.code == 'account-exists-with-different-credential') {
        throw FirebaseAuthException(
          code: 'account-exists-with-different-credential',
          message: 'اکاؤنٹ پہلے سے موجود ہے۔ براہ کرم ای میل اور پاس ورڈ سے لاگ ان کریں۔',
        );
      }
      // Re-throw other Firebase exceptions
      rethrow;
    }
  }
}
