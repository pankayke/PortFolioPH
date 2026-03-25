// lib/presentation/screens/auth/login_screen.dart (REDESIGNED)
// ─────────────────────────────────────────────────────────────────────────────
// Premium login screen with glassmorphism, responsive design,
// and enhanced authentication experience
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/utils/validators.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/widgets/glass/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      _showErrorBanner(auth.errorMessage ?? 'Login failed. Please try again.');
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) =>
          _ForgotPasswordDialog(emailController: emailController),
    );
  }

  void _showErrorBanner(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = context.watch<AuthProvider>().isLoading;
    final isMobile = MediaQuery.of(context).size.width < 640;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withAlpha(20),
              colorScheme.primaryContainer.withAlpha(15),
              colorScheme.secondary.withAlpha(10),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 32 : 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 48),

                    // Glass container with form
                    GlassContainer(
                      width: double.infinity,
                      borderRadius: 24,
                      blurStrength: 24,
                      saturation: 160,
                      opacity: isMobile ? 0.15 : 0.18,
                      padding: EdgeInsets.all(isMobile ? 32 : 48),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Form title
                            Text(
                              'Welcome Back',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Showcase your talent and connect with opportunities',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppConstants.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email field
                            GlassInputField(
                              controller: _emailController,
                              label: 'Email Address',
                              hintText: 'you@example.com',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(
                                Icons.mail_outline_rounded,
                                color: AppConstants.primaryColor,
                                size: 20,
                              ),
                              validator: AppValidators.validateEmail,
                              autofillHints: const [AutofillHints.email],
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            GlassInputField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: '••••••••',
                              obscureText: true,
                              isPassword: true,
                              showPasswordToggle: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: AppConstants.primaryColor,
                                size: 20,
                              ),
                              validator: AppValidators.validatePasswordLogin,
                              autofillHints: const [AutofillHints.password],
                              onEditingComplete: _handleLogin,
                            ),
                            const SizedBox(height: 16),

                            // Remember me + Forgot password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Remember me checkbox
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _rememberMe = !_rememberMe);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: _rememberMe
                                              ? AppConstants.primaryColor
                                              : Colors.white.withAlpha(40),
                                          border: Border.all(
                                            color: _rememberMe
                                                ? AppConstants.primaryColor
                                                : Colors.white.withAlpha(80),
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: _rememberMe
                                            ? const Center(
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Remember me',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: AppConstants.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Forgot password link
                                TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppConstants.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Login button
                            GlassButton(
                              label: 'Sign In',
                              icon: Icons.arrow_forward_rounded,
                              fullWidth: true,
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _handleLogin,
                            ),
                            const SizedBox(height: 24),

                            // Social divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withAlpha(40),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'Or continue with',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppConstants.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withAlpha(40),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Social login buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  icon: Icons.language_rounded,
                                  label: 'Google',
                                  onPressed: () {
                                    // Handle Google login
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildSocialButton(
                                  icon: Icons.work_outline_rounded,
                                  label: 'LinkedIn',
                                  onPressed: () {
                                    // Handle LinkedIn login
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildSocialButton(
                                  icon: Icons.code_rounded,
                                  label: 'GitHub',
                                  onPressed: () {
                                    // Handle GitHub login
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Register link
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppConstants.textSecondary,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () => context.go('/register'),
                                        child: Text(
                                          'Sign up here',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    AppConstants.primaryColor,
                                                fontWeight: FontWeight.w700,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.primaryColor,
                Color.lerp(AppConstants.primaryColor, Colors.white, 0.22)!,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: const Offset(0, 8),
                color: AppConstants.primaryColor.withAlpha(80),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.work_rounded, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        // Title
        Text(
          'PortFolioPH',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Flag
        const Text('🇵🇭', style: TextStyle(fontSize: 20)),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(77), width: 1),
          color: Colors.white.withAlpha(30),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Icon(icon, color: AppConstants.primaryColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

/// Forgot Password Dialog
class _ForgotPasswordDialog extends StatefulWidget {
  final TextEditingController emailController;

  const _ForgotPasswordDialog({required this.emailController});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  Future<void> _handleReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(
      email: widget.emailController.text.trim(),
      newPassword: '', // Will be sent via email
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Reset link sent to your email'
              : auth.errorMessage ?? 'Failed to send reset link',
        ),
        backgroundColor: success ? Colors.green : AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        width: 380,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email and we\'ll send you a link to reset your password',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GlassInputField(
                controller: widget.emailController,
                label: 'Email Address',
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(
                  Icons.mail_outline_rounded,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                validator: AppValidators.validateEmail,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Cancel',
                      style: GlassButtonStyle.secondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      label: 'Send Link',
                      onPressed: _handleReset,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
