// lib/presentation/screens/auth/login_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Login screen – Sprint 2 full implementation.
//
// Calls AuthProvider.login(); shows SnackBar on error.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/core/utils/validators.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  int _taglineIndex = 0;

  static const List<String> _motivationLines = [
    'Mag-apply na! 💪',
    'Good luck, kabayan 🇵🇭',
    'Build your future, one opportunity at a time.',
  ];

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController(text: _emailController.text);
    final tokenController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool requestingToken = false;
    String? helperText;

    final didSubmit = await showDialog<Map<String, String>?>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Forgot Password'),
              content: Form(
                key: dialogFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Registered Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: AppValidators.validateEmail,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      TextFormField(
                        controller: tokenController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Reset Token',
                          prefixIcon: Icon(Icons.password_outlined),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Reset token is required.'
                            : null,
                      ),
                      if (helperText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          helperText!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: AppConstants.spacingMd),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setDialogState(() => obscureNew = !obscureNew),
                          ),
                        ),
                        validator: AppValidators.validatePassword,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setDialogState(
                              () => obscureConfirm = !obscureConfirm,
                            ),
                          ),
                        ),
                        validator: (v) => AppValidators.validateConfirmPassword(
                          v,
                          newPasswordController.text,
                        ),
                        onFieldSubmitted: (_) {
                          if (dialogFormKey.currentState?.validate() ?? false) {
                            Navigator.of(dialogContext).pop({
                              'email': emailController.text.trim(),
                              'token': tokenController.text.trim(),
                              'newPassword': newPasswordController.text,
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: requestingToken
                      ? null
                      : () async {
                          final emailError = AppValidators.validateEmail(
                            emailController.text,
                          );
                          if (emailError != null) {
                            setDialogState(() => helperText = emailError);
                            return;
                          }

                          setDialogState(() {
                            requestingToken = true;
                            helperText = null;
                          });

                          final auth = context.read<AuthProvider>();
                          final token = await auth.requestPasswordReset(
                            email: emailController.text.trim(),
                          );

                          if (!mounted) return;

                          setDialogState(() {
                            requestingToken = false;
                            if (token != null && token.isNotEmpty) {
                              tokenController.text = token;
                              helperText =
                                  'Reset token generated. Use it to confirm password reset.';
                            } else {
                              helperText =
                                  'If the email exists, a reset token was issued.';
                            }
                          });
                        },
                  child: requestingToken
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Request Token'),
                ),
                FilledButton(
                  onPressed: () {
                    if (dialogFormKey.currentState?.validate() ?? false) {
                      Navigator.of(dialogContext).pop({
                        'email': emailController.text.trim(),
                        'token': tokenController.text.trim(),
                        'newPassword': newPasswordController.text,
                      });
                    }
                  },
                  child: const Text('Reset Password'),
                ),
              ],
            );
          },
        );
      },
    );

    if (didSubmit == null || !mounted) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.confirmPasswordReset(
      email: didSubmit['email'] ?? '',
      token: didSubmit['token'] ?? '',
      newPassword: didSubmit['newPassword'] ?? '',
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _emailController.text = didSubmit['email'] ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully. You can now log in.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Password reset failed.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), _rotateTagline);
  }

  void _rotateTagline() {
    if (!mounted) return;
    setState(() {
      _taglineIndex = (_taglineIndex + 1) % _motivationLines.length;
    });
    Future<void>.delayed(const Duration(seconds: 2), _rotateTagline);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final role = auth.currentUser?.role;
      context.go(
        role == AppConstants.roleRecruiter
            ? AppRoutes.recruiterDashboard
            : AppRoutes.dashboard,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colorScheme.primary, colorScheme.primaryContainer],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.outlineVariant),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 24,
                        offset: Offset(0, 10),
                        color: Color(0x22000000),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.work_outline_rounded,
                          size: 52,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back. Continue building your portfolio.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Text(
                            _motivationLines[_taglineIndex],
                            key: ValueKey(_taglineIndex),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 6,
                          runSpacing: 6,
                          children: const [
                            Chip(label: Text('50k+ users')),
                            Chip(label: Text('10k jobs posted')),
                            Chip(label: Text('₱500M salaries')),
                            Chip(label: Text('Cebu')),
                            Chip(label: Text('Manila')),
                            Chip(label: Text('Davao')),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingLg),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: AppValidators.validateEmail,
                        ),
                        const SizedBox(height: AppConstants.spacingMd),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Password is required.'
                              : null,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : _showForgotPasswordDialog,
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSm),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Log In'),
                          ),
                        ),

                        const SizedBox(height: AppConstants.spacingMd),

                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text("Don't have an account? Sign Up"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
