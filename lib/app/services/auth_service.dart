
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/app_user.dart';

class AuthService extends GetxService {
  AuthService();

  static AuthService get to => Get.find<AuthService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    final doc =
        await _firestore.collection('users').doc(user.uid).get(const GetOptions(source: Source.serverAndCache));

    if (doc.exists) {
      currentUser.value = AppUser.fromMap(user.uid, doc.data());
    } else {
      final fallback = AppUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        role: 'user',
      );
      await _firestore.collection('users').doc(user.uid).set(fallback.toMap(), SetOptions(merge: true));
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
    await _firestore.collection('users').doc(user.uid).set(profile.toMap(), SetOptions(merge: true));
    currentUser.value = profile;
    return credential;
  }

  Future<void> signOut() async {
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
}

