// lib/presentation/screens/auth/register_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Registration screen – Sprint 2 full implementation.
//
// Form fields:
//   • Full name  (optional)
//   • Username   (required, unique)
//   • Email      (required, valid format, unique)
//   • Password   (required, min-length + letter + digit)
//   • Confirm password (must match)
//
// Behaviour:
//   • Real-time inline validation on every keystroke (autovalidateMode: always).
//   • Submit button disabled while form is invalid or loading.
//   • On success  → navigate to /profile-setup.
//   • On failure  → SnackBar with error from AuthProvider.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/utils/validators.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _formValid = false;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _fullNameController,
      _usernameController,
      _emailController,
      _passwordController,
      _confirmController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  /// Recomputes [_formValid] by running validators against the current raw
  /// values WITHOUT calling [FormState.validate()], which would force all
  /// unvisited fields into their error state and defeat
  /// [AutovalidateMode.onUserInteraction].
  void _onFieldChanged() {
    final valid =
        AppValidators.validateUsername(_usernameController.text) == null &&
        AppValidators.validateEmail(_emailController.text) == null &&
        AppValidators.validatePassword(_passwordController.text) == null &&
        AppValidators.validateConfirmPassword(
              _confirmController.text,
              _passwordController.text,
            ) ==
            null;
    if (valid != _formValid) setState(() => _formValid = valid);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim().isEmpty
          ? null
          : _fullNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/profile-setup');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed.'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ──────────────────────────────────────────
                      const Icon(
                        Icons.person_add_outlined,
                        size: 56,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        AppConstants.appTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppConstants.spacingXl),

                      // ── Full name (optional) ─────────────────────────────
                      TextFormField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full Name (optional)',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),

                      // ── Username ─────────────────────────────────────────
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                        validator: AppValidators.validateUsername,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),

                      // ── Email ────────────────────────────────────────────
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

                      // ── Password ─────────────────────────────────────────
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
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
                        validator: AppValidators.validatePassword,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),

                      // ── Confirm password ─────────────────────────────────
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_person_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                        validator: (v) => AppValidators.validateConfirmPassword(
                          v,
                          _passwordController.text,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingLg),

                      // ── Submit button ────────────────────────────────────
                      ElevatedButton(
                        onPressed: (isLoading || !_formValid) ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),

                      // ── Login link ───────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context.go('/login'),
                            child: const Text('Log In'),
                          ),
                        ],
                      ),
                    ],
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
