import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildLogo(),
              const SizedBox(height: 28),

              // ── Tab switcher ─────────────────────────────────────────────
              Obx(() => _buildTabBar()),
              const SizedBox(height: 28),

              // ── Tab content ──────────────────────────────────────────────
              Obx(() {
                switch (controller.activeTab.value) {
                  case AuthTab.login:
                    return _buildLoginForm();
                  case AuthTab.register:
                    return _buildRegisterForm();
                  case AuthTab.forgot:
                    return _buildForgotForm();
                }
              }),

              const SizedBox(height: 20),

              // ── Social buttons (only on login/register) ──────────────────
              Obx(() {
                if (controller.activeTab.value == AuthTab.forgot) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    _buildDivider(),
                    const SizedBox(height: 16),
                    _SocialButton(
                      onTap: controller.activeTab.value == AuthTab.login
                          ? controller.loginWithGoogle
                          : controller.signupWithGoogle,
                      icon: const _GoogleSvgIcon(),
                      label: controller.activeTab.value == AuthTab.login
                          ? 'Continue with Google'
                          : 'Sign up with Google',
                      backgroundColor: Colors.white,
                      textColor: AppColors.textDark,
                      borderColor: Colors.grey.shade300,
                      isLoading: controller.isLoadingGoogle.value,
                      isBusy: controller.isLoadingEmail.value,
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logo ──────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'MD SCENTS',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        Text(
          'Dynamic Perfumes',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.45),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Sign In',
            active: controller.activeTab.value == AuthTab.login,
            onTap: () => controller.setTab(AuthTab.login),
          ),
          _TabButton(
            label: 'Sign Up',
            active: controller.activeTab.value == AuthTab.register,
            onTap: () => controller.setTab(AuthTab.register),
          ),
          _TabButton(
            label: 'Forgot',
            active: controller.activeTab.value == AuthTab.forgot,
            onTap: () => controller.setTab(AuthTab.forgot),
          ),
        ],
      ),
    );
  }

  // ── Login form ────────────────────────────────────────────────────────────

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InputField(
          controller: controller.emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        Obx(
          () => _InputField(
            controller: controller.passwordController,
            hint: 'Password',
            icon: Icons.lock_outline,
            obscure: controller.obscurePassword.value,
            onToggleObscure: controller.togglePasswordVisibility,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => controller.setTab(AuthTab.forgot),
            child: Text(
              'Forgot password?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => _PrimaryButton(
            label: 'Sign In',
            icon: Icons.login_rounded,
            isLoading: controller.isLoadingEmail.value,
            isBusy: controller.isLoadingGoogle.value,
            onTap: controller.loginWithEmail,
          ),
        ),
        const SizedBox(height: 14),
        _switchPrompt(
          question: "Don't have an account?",
          action: 'Sign Up',
          onTap: () => controller.setTab(AuthTab.register),
        ),
      ],
    );
  }

  // ── Register form ─────────────────────────────────────────────────────────

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InputField(
          controller: controller.nameController,
          hint: 'Full name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _InputField(
          controller: controller.emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        Obx(
          () => _InputField(
            controller: controller.passwordController,
            hint: 'Password',
            icon: Icons.lock_outline,
            obscure: controller.obscurePassword.value,
            onToggleObscure: controller.togglePasswordVisibility,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _InputField(
            controller: controller.confirmPasswordController,
            hint: 'Confirm password',
            icon: Icons.lock_outline,
            obscure: controller.obscureConfirm.value,
            onToggleObscure: controller.toggleConfirmVisibility,
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => _PrimaryButton(
            label: 'Create Account',
            icon: Icons.person_add_outlined,
            isLoading: controller.isLoadingEmail.value,
            isBusy: controller.isLoadingGoogle.value,
            onTap: controller.registerWithEmail,
          ),
        ),
        const SizedBox(height: 14),
        _switchPrompt(
          question: 'Already have an account?',
          action: 'Sign In',
          onTap: () => controller.setTab(AuthTab.login),
        ),
      ],
    );
  }

  // ── Forgot password form ──────────────────────────────────────────────────

  Widget _buildForgotForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Enter your account email. We\'ll send a reset link check inbox & spam. Same flow for customers and admins using email & password.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _InputField(
          controller: controller.emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        Obx(
          () => _PrimaryButton(
            label: 'Send Reset Link',
            icon: Icons.send_outlined,
            isLoading: controller.isLoadingEmail.value,
            isBusy: controller.isLoadingGoogle.value,
            onTap: controller.sendPasswordReset,
          ),
        ),
        const SizedBox(height: 14),
        _switchPrompt(
          question: 'Remembered it?',
          action: 'Back to Sign In',
          onTap: () => controller.setTab(AuthTab.login),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or continue with',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _switchPrompt({
    required String question,
    required String action,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tab button ────────────────────────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: active
                    ? Colors.white
                    : AppColors.textDark.withValues(alpha: 0.45),
                fontWeight: active ? FontWeight.w700 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType type;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.type = TextInputType.text,
  });

  Iterable<String>? get _autofillHints {
    if (obscure) return const [AutofillHints.password];
    if (type == TextInputType.emailAddress) {
      return const [AutofillHints.email];
    }
    if (hint.toLowerCase().contains('name')) {
      return const [AutofillHints.name];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        autocorrect: false,
        enableSuggestions: !obscure,
        autofillHints: _autofillHints,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDark),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.35),
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.textDark.withValues(alpha: 0.45),
            size: 20,
          ),
          suffixIcon: onToggleObscure != null
              ? GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textDark.withValues(alpha: 0.45),
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// ── Primary button ────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;

  /// True while the other auth path (e.g. Google) is in progress — disables tap, no spinner.
  final bool isBusy;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    this.isBusy = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final blocked = isLoading || isBusy;
    return GestureDetector(
      onTap: blocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D3A5C), AppColors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Text(label, style: AppTextStyles.buttonText),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Social button ─────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final bool isLoading;

  /// True while email/password flow is in progress — disables tap, no spinner.
  final bool isBusy;

  const _SocialButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.isLoading = false,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final blocked = isLoading || isBusy;
    return GestureDetector(
      onTap: blocked ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: blocked && !isLoading ? 0.55 : 1,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: borderColor != null
                ? Border.all(color: borderColor!)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor.withValues(alpha: 0.85),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon,
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: AppTextStyles.buttonText.copyWith(
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Real Google SVG icon ──────────────────────────────────────────────────────

class _GoogleSvgIcon extends StatelessWidget {
  const _GoogleSvgIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Draw the four colored arcs of the Google "G"
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Red arc (top-right)
    canvas.drawArc(
      rect,
      -0.52,
      1.57,
      false,
      Paint()
        ..color = const Color(0xFFEA4335)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.butt,
    );

    // Yellow arc (bottom-right)
    canvas.drawArc(
      rect,
      1.05,
      1.05,
      false,
      Paint()
        ..color = const Color(0xFFFBBC05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.butt,
    );

    // Green arc (bottom-left)
    canvas.drawArc(
      rect,
      2.1,
      1.05,
      false,
      Paint()
        ..color = const Color(0xFF34A853)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.butt,
    );

    // Blue arc (top-left)
    canvas.drawArc(
      rect,
      3.15,
      1.63,
      false,
      Paint()
        ..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.butt,
    );

    // White horizontal bar of the "G"
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - size.height * 0.09, r * 0.85, size.height * 0.18),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
