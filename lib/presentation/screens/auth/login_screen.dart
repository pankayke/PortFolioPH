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
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    bool obscureNew = true;
    bool obscureConfirm = true;

    final didSubmit = await showDialog<bool>(
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
                            Navigator.of(dialogContext).pop(true);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (dialogFormKey.currentState?.validate() ?? false) {
                      Navigator.of(dialogContext).pop(true);
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

    if (didSubmit != true || !mounted) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.resetPassword(
      email: emailController.text.trim(),
      newPassword: newPasswordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _emailController.text = emailController.text.trim();
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
      context.go('/dashboard');
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
