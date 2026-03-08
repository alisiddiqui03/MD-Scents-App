import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/routes/app_pages.dart';
import 'package:get/get.dart';

import '../../../../app/services/auth_service.dart';
import '../../../../app/theme/app_colors.dart';

enum AuthTab { login, register, forgot }

class AuthController extends GetxController {
  // ── Text controllers ──────────────────────────────────────────────────────
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── Observables ───────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirm = true.obs;
  final activeTab = AuthTab.login.obs;

  final AuthService _authService = AuthService.to;

  // ── Tab switching ─────────────────────────────────────────────────────────
  void setTab(AuthTab tab) {
    activeTab.value = tab;
    // Clear fields when switching tabs
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmVisibility() =>
      obscureConfirm.value = !obscureConfirm.value;

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _snack('Missing Information', 'Please enter your email and password.');
      return;
    }
    if (!GetUtils.isEmail(email)) {
      _snack('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    try {
      isLoading.value = true;
      // ── TODO: Replace with real Firebase Auth ──────────────────────────
      // await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: email, password: password);
      // ──────────────────────────────────────────────────────────────────
      final asAdmin = email.toLowerCase().contains('admin');
      await _authService.debugSetMockUser(email: email, asAdmin: asAdmin);
      if (asAdmin) {
        Get.offAllNamed(Routes.ADMIN_BASE);
      } else {
        Get.offAllNamed(Routes.USER_BASE);
      }
    } catch (e) {
      _snack('Sign In Failed', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────
  Future<void> registerWithEmail() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (name.isEmpty) {
      _snack('Missing Name', 'Please enter your full name.');
      return;
    }
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      _snack('Invalid Email', 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _snack('Weak Password', 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      _snack('Password Mismatch', 'Passwords do not match.');
      return;
    }

    try {
      isLoading.value = true;
      // ── TODO: Replace with real Firebase Auth ──────────────────────────
      // final cred = await FirebaseAuth.instance
      //     .createUserWithEmailAndPassword(email: email, password: password);
      // await cred.user?.updateDisplayName(name);
      // Save user doc to Firestore:
      // await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
      //   'uid': cred.user!.uid, 'email': email,
      //   'displayName': name, 'role': 'user',
      //   'createdAt': FieldValue.serverTimestamp(),
      // });
      // ──────────────────────────────────────────────────────────────────
      await _authService.debugSetMockUser(email: email, asAdmin: false);
      Get.offAllNamed(Routes.USER_BASE);
    } catch (e) {
      _snack('Sign Up Failed', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ── Forgot Password ───────────────────────────────────────────────────────
  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      _snack('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    try {
      isLoading.value = true;
      // ── TODO: Replace with real Firebase Auth ──────────────────────────
      // await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // ──────────────────────────────────────────────────────────────────
      await Future.delayed(const Duration(seconds: 1)); // simulate network
      Get.snackbar(
        'Email Sent',
        'Password reset link sent to $email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.mark_email_read_outlined, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
      setTab(AuthTab.login);
    } catch (e) {
      _snack('Failed', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    // ── TODO: Wire with google_sign_in + firebase_auth ─────────────────────
    // final googleUser = await GoogleSignIn().signIn();
    // final googleAuth = await googleUser?.authentication;
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth?.accessToken,
    //   idToken: googleAuth?.idToken,
    // );
    // await FirebaseAuth.instance.signInWithCredential(credential);
    // ──────────────────────────────────────────────────────────────────────
    _snack('Coming Soon', 'Google Sign-In will be wired with Firebase.');
  }

  // ── Phone / OTP ───────────────────────────────────────────────────────────
  Future<void> loginWithPhone() async {
    // ── TODO: Wire with FirebaseAuth.instance.verifyPhoneNumber ────────────
    // FirebaseAuth.instance.verifyPhoneNumber(
    //   phoneNumber: '+92xxxxxxxxxx',
    //   verificationCompleted: ...,
    //   verificationFailed: ...,
    //   codeSent: (verificationId, _) { ... show OTP dialog ... },
    //   codeAutoRetrievalTimeout: ...,
    // );
    // ──────────────────────────────────────────────────────────────────────
    _snack('Coming Soon', 'Phone/OTP Sign-In will be wired with Firebase.');
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  void _snack(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
      icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
