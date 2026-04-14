import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../services/onesignal_service.dart';
import '../config/google_auth_config.dart';
import '../data/models/app_user.dart';
import '../exceptions/google_account_link_exception.dart';
import 'firestore_service.dart';

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
      // Android: helps OAuth exchange; avoids reusing an old refresh path without tokens.
      forceCodeForRefreshToken: true,
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

  /// Reload Firestore profile into [currentUser] (e.g. after referral code is assigned).
  Future<void> refreshProfile() async {
    final u = _auth.currentUser;
    if (u == null) return;
    await _loadUserProfile(u);
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
        referralCode: null,
        referredBy: null,
        points: 0,
      );
      await _firestore.collection('users').doc(user.uid).set({
        ...fallback.toMap(),
        'wallet': {'balance': 0.0, 'pendingRewards': 0.0},
      }, SetOptions(merge: true));
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
      referralCode: 'DEBUG123',
      referredBy: null,
    );
    currentUser.value = mockUser;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _loadUserProfile(credential.user!);
    await _syncOneSignalPlayerId(credential.user!.uid);
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
      referralCode: null,
      referredBy: null,
      points: 0,
    );
    await _firestore.collection('users').doc(user.uid).set({
      ...profile.toMap(),
      'wallet': {'balance': 0.0, 'pendingRewards': 0.0},
    }, SetOptions(merge: true));
    currentUser.value = profile;
    await _syncOneSignalPlayerId(user.uid);
    return credential;
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
    } catch (_) {
      // Ignore if Google Sign-In was never used or plugin state is stale.
    }
    try {
      await OneSignalService.signOutCleanup();
    } catch (_) {}
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

  Future<void> deleteCurrentUser({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in.',
      );
    }

    final providerIds = user.providerData.map((p) => p.providerId).toSet();

    if (providerIds.contains('password')) {
      final email = user.email?.trim();
      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message:
              'Unable to determine your email address for reauthentication.',
        );
      }
      if (password == null || password.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'requires-recent-login',
          message: 'Password is required to delete your account.',
        );
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password.trim(),
      );
      await user.reauthenticateWithCredential(credential);
    } else if (providerIds.contains('google.com')) {
      final googleUser = await _googleSignInClient.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-aborted',
          message: 'Google sign-in was cancelled. Please try again.',
        );
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Unable to authenticate with Google.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(credential);
    } else {
      throw FirebaseAuthException(
        code: 'unsupported-provider',
        message:
            'Your sign-in method does not support direct account deletion. Please sign in again and try again.',
      );
    }

    final uid = user.uid;
    final currentAppUser = currentUser.value;
    await _deleteUserDataFromFirestore(uid, currentAppUser?.referralCode);

    try {
      await OneSignalService.signOutCleanup();
    } catch (_) {}

    await user.delete();
    currentUser.value = null;
    firebaseUser.value = null;
  }

  Future<void> _deleteUserDataFromFirestore(
    String uid,
    String? referralCode,
  ) async {
    if (referralCode != null && referralCode.trim().isNotEmpty) {
      await FirestoreService.referralCodesCollection
          .doc(referralCode.trim())
          .delete()
          .catchError((_) {});
    }

    await _deleteUserCollection(FirestoreService.usersOrdersRef(uid));
    await _deleteUserCollection(FirestoreService.usersWishlistRef(uid));
    await _deleteUserCollection(FirestoreService.usersAddressesRef(uid));
    await _deleteUserCollection(
      FirestoreService.usersCollection.doc(uid).collection('referrals'),
    );
    await _deleteUserReviews(uid);

    await FirestoreService.usersCollection.doc(uid).delete().catchError((_) {});
  }

  Future<void> _deleteUserCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final snapshot = await collection.limit(300).get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = FirestoreService.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> _deleteUserReviews(String uid) async {
    while (true) {
      final snapshot = await FirestoreService.usersReviewsRef(
        uid,
      ).limit(300).get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = FirestoreService.instance.batch();
      for (final doc in snapshot.docs) {
        final productId = doc.id;
        batch.delete(doc.reference);
        batch.delete(FirestoreService.productReviewsRef(productId).doc(uid));
      }
      await batch.commit();
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kGoogleOAuthWebClientId.trim().isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-credential',
        message:
            'Google Web client ID is not set. Add kGoogleOAuthWebClientId in '
            'lib/app/config/google_auth_config.dart (Firebase → Authentication → Google → Web client ID).',
      );
    }

    // Clear cached Google session (stale ID token on wrong device time / cached creds).
    try {
      await _googleSignInClient.signOut();
    } catch (_) {}
    try {
      await _googleSignInClient.disconnect();
    } catch (_) {}

    final GoogleSignInAccount? googleUser = await _googleSignInClient.signIn();

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
      await _syncOneSignalPlayerId(credentialResult.user!.uid);
      return credentialResult;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        final email = (e.email?.trim().isNotEmpty ?? false)
            ? e.email!.trim()
            : googleUser.email.trim();
        if (email.isEmpty) {
          throw FirebaseAuthException(
            code: 'account-exists-with-different-credential',
            message:
                'This email is already registered with another sign-in method. '
                'Sign in with email and password first.',
          );
        }
        throw GoogleAccountNeedsPasswordException(
          email: email,
          googleCredential: credential,
        );
      }
      rethrow;
    }
  }

  /// After [signInWithGoogle] throws [GoogleAccountNeedsPasswordException],
  /// sign in with the existing email/password account and link the Google credential.
  Future<UserCredential> linkGoogleAfterEmailPassword({
    required String email,
    required String password,
    required OAuthCredential googleCredential,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await userCredential.user!.linkWithCredential(googleCredential);
    await _loadUserProfile(userCredential.user!);
    await _syncOneSignalPlayerId(userCredential.user!.uid);
    return userCredential;
  }

  Future<void> _syncOneSignalPlayerId(String uid) async {
    try {
      await OneSignalService.savePlayerIdToFirestore(uid);
    } catch (_) {}
  }
}
