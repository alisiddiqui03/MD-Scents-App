import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/exceptions/google_account_link_exception.dart';
import '../../../../app/services/auth_service.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/utils/auth_error_messages.dart';

enum AuthTab { login, register, forgot }

class AuthController extends GetxController {
  // ── Text controllers ──────────────────────────────────────────────────────
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── Observables ───────────────────────────────────────────────────────────
  /// Email / password / reset flows — spinner on primary button only.
  final isLoadingEmail = false.obs;
  /// Google sign-in — spinner on Google button only.
  final isLoadingGoogle = false.obs;
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
      isLoadingEmail.value = true;
      await _authService.signInWithEmail(email, password);

      if (_authService.isAdmin) {
        Get.offAllNamed(Routes.ADMIN_BASE);
      } else {
        Get.offAllNamed(Routes.USER_BASE);
      }
    } on FirebaseAuthException catch (e) {
      _snack('Sign In Failed', userFacingAuthError(e));
    } catch (e) {
      _snack('Sign In Failed', userFacingAuthError(e));
    } finally {
      isLoadingEmail.value = false;
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
      isLoadingEmail.value = true;
      await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: name,
      );
      Get.offAllNamed(Routes.USER_BASE);
    } on FirebaseAuthException catch (e) {
      _snack('Sign Up Failed', userFacingAuthError(e));
    } catch (e) {
      _snack('Sign Up Failed', userFacingAuthError(e));
    } finally {
      isLoadingEmail.value = false;
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
      isLoadingEmail.value = true;
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
      _snack('Could not send reset email', _resetEmailMessage(e));
    } catch (e) {
      _snack('Could not send reset email', userFacingAuthError(e));
    } finally {
      isLoadingEmail.value = false;
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
    try {
      isLoadingGoogle.value = true;
      await _authService.signInWithGoogle();
      _navigateAfterGoogleAuth();
    } on GoogleAccountNeedsPasswordException catch (e) {
      isLoadingGoogle.value = false;
      await _promptPasswordAndLinkGoogle(e);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'google-sign-in-aborted') return;
      _snack('Google Sign-In Failed', userFacingAuthError(e));
    } catch (e) {
      _snack('Google Sign-In Failed', userFacingAuthError(e));
    } finally {
      isLoadingGoogle.value = false;
    }
  }

  // ── Google Sign-Up ────────────────────────────────────────────────────────
  Future<void> signupWithGoogle() async {
    try {
      isLoadingGoogle.value = true;
      await _authService.signInWithGoogle();
      _navigateAfterGoogleAuth();
    } on GoogleAccountNeedsPasswordException catch (e) {
      isLoadingGoogle.value = false;
      await _promptPasswordAndLinkGoogle(e);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'google-sign-in-aborted') return;
      _snack('Google Sign-Up Failed', userFacingAuthError(e));
    } catch (e) {
      _snack('Google Sign-Up Failed', userFacingAuthError(e));
    } finally {
      isLoadingGoogle.value = false;
    }
  }

  void _navigateAfterGoogleAuth() {
    if (_authService.isAdmin) {
      Get.offAllNamed(Routes.ADMIN_BASE);
    } else {
      Get.offAllNamed(Routes.USER_BASE);
    }
  }

  Future<void> _promptPasswordAndLinkGoogle(
    GoogleAccountNeedsPasswordException e,
  ) async {
    final password = await _showLinkPasswordDialog(e.email);
    if (password == null || password.isEmpty) return;

    try {
      isLoadingGoogle.value = true;
      await _authService.linkGoogleAfterEmailPassword(
        email: e.email,
        password: password,
        googleCredential: e.googleCredential,
      );
      _navigateAfterGoogleAuth();
    } on FirebaseAuthException catch (err) {
      _snack('Link failed', userFacingAuthError(err));
    } catch (err) {
      _snack('Link failed', userFacingAuthError(err));
    } finally {
      isLoadingGoogle.value = false;
    }
  }

  Future<String?> _showLinkPasswordDialog(String email) async {
    final ctrl = TextEditingController();
    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('اکاؤنٹ جوڑیں'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'یہ Google والی ای میل پہلے سے ای میل اور پاس ورڈ سے رجسٹر ہے۔ '
                'ایک بار اپنا پاس ورڈ درج کریں تاکہ Google سائن ان منسلک ہو جائے۔',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                email,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'پاس ورڈ',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) =>
                    Get.back(result: ctrl.text.trim()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('منسوخ'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: ctrl.text.trim()),
            child: const Text('جاری رکھیں'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    ctrl.dispose();
    return result;
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
