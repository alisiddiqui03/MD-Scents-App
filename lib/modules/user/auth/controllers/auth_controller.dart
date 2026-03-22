import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/services/auth_service.dart';
import '../../../../app/routes/app_pages.dart';
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
    // Avoid wiping email when opening "Forgot password" from Sign In.
    switch (tab) {
      case AuthTab.login:
        nameController.clear();
        confirmPasswordController.clear();
        break;
      case AuthTab.register:
        emailController.clear();
        passwordController.clear();
        nameController.clear();
        confirmPasswordController.clear();
        break;
      case AuthTab.forgot:
        passwordController.clear();
        nameController.clear();
        confirmPasswordController.clear();
        break;
    }
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmVisibility() =>
      obscureConfirm.value = !obscureConfirm.value;

  // ── Sign In (Firebase Email/Password) ─────────────────────────────────────
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
      await _authService.signInWithEmail(email, password);

      if (_authService.isAdmin) {
        Get.offAllNamed(Routes.ADMIN_BASE);
      } else {
        Get.offAllNamed(Routes.USER_BASE);
      }
    } on FirebaseAuthException catch (e) {
      _snack('Sign In Failed', e.message ?? e.code);
    } catch (e) {
      _snack('Sign In Failed', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ── Sign Up (Firebase Email/Password) ─────────────────────────────────────
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
      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: name,
      );
      Get.offAllNamed(Routes.USER_BASE);
    } on FirebaseAuthException catch (e) {
      _snack('Sign Up Failed', e.message ?? e.code);
    } catch (e) {
      _snack('Sign Up Failed', e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ── Forgot Password (Firebase — same flow for customers & admin emails) ─
  Future<void> sendPasswordReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      _snack('Invalid Email', 'Please enter a valid email address.');
      return;
    }

    try {
      isLoading.value = true;
      await _authService.sendPasswordResetEmail(email);
      Get.snackbar(
        'Check your email',
        'We sent a reset link to $email. Open it, choose a new password, then sign in here.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.mark_email_read_outlined, color: Colors.white),
        duration: const Duration(seconds: 5),
      );
      setTab(AuthTab.login);
    } on FirebaseAuthException catch (e) {
      _snack(
        'Could not send reset email',
        _resetEmailMessage(e),
      );
    } catch (e) {
      _snack('Could not send reset email',
          e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  String _resetEmailMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-not-found':
        return 'No account uses this email. Sign up or check the spelling.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a few minutes and try again.';
      default:
        return e.message ?? e.code;
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
