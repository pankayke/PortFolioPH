// lib/presentation/screens/auth/register_screen.dart (REDESIGNED)
// ─────────────────────────────────────────────────────────────────────────────
// Premium registration screen with glassmorphism and multi-step design
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/utils/validators.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';
import 'package:portfolioph/presentation/widgets/glass/index.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _professionController;

  bool _agreedToTerms = false;
  String? _passwordStrength;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _professionController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String value) {
    String strength = 'Weak';
    if (value.length >= 10) strength = 'Strong';
    if (value.length >= 8 && RegExp(r'[A-Z]').hasMatch(value)) {
      strength = 'Medium';
    }
    setState(() => _passwordStrength = strength);
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showErrorBanner('Please fill in all fields correctly.');
      return;
    }

    if (!_agreedToTerms) {
      _showErrorBanner(
        'Please agree to the Terms of Service and Privacy Policy.',
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _emailController.text.trim().split(
        '@',
      )[0], // Use email prefix as username
      fullName: _fullNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/profile-setup');
    } else {
      _showErrorBanner(
        auth.errorMessage ?? 'Registration failed. Please try again.',
      );
    }
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
                              'Create Your Account',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Build your portfolio, land opportunities, and grow your career',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppConstants.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Full name field
                            GlassInputField(
                              controller: _fullNameController,
                              label: 'Full Name',
                              hintText: 'Your full name',
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: AppConstants.primaryColor,
                                size: 20,
                              ),
                              validator: (value) =>
                                  AppValidators.validateRequired(
                                    value,
                                    fieldName: 'Full name',
                                  ),
                              autofillHints: const [AutofillHints.name],
                            ),
                            const SizedBox(height: 16),

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
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: AppConstants.primaryColor,
                                size: 20,
                              ),
                              validator: AppValidators.validatePassword,
                              autofillHints: const [AutofillHints.newPassword],
                              onChanged: _updatePasswordStrength,
                            ),
                            if (_passwordStrength != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: _passwordStrength == 'Weak'
                                            ? 0.33
                                            : _passwordStrength == 'Medium'
                                            ? 0.66
                                            : 1.0,
                                        minHeight: 4,
                                        backgroundColor: Colors.white.withAlpha(
                                          40,
                                        ),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              _passwordStrength == 'Weak'
                                                  ? AppConstants.errorColor
                                                  : _passwordStrength ==
                                                        'Medium'
                                                  ? Colors.orange
                                                  : Colors.green,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _passwordStrength ?? '',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: _passwordStrength == 'Weak'
                                                ? AppConstants.errorColor
                                                : _passwordStrength == 'Medium'
                                                ? Colors.orange
                                                : Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),

                            // Confirm password field
                            GlassInputField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hintText: '••••••••',
                              obscureText: true,
                              isPassword: true,
                              showPasswordToggle: true,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(
                                Icons.lock_reset_outlined,
                                color: AppConstants.primaryColor,
                                size: 20,
                              ),
                              validator: (value) =>
                                  AppValidators.validateConfirmPassword(
                                    value,
                                    _passwordController.text,
                                  ),
                              autofillHints: const [AutofillHints.newPassword],
                            ),
                            const SizedBox(height: 16),

                            // Profession dropdown
                            _buildProfessionDropdown(theme),
                            const SizedBox(height: 24),

                            // Terms checkbox
                            _buildTermsCheckbox(theme),
                            const SizedBox(height: 32),

                            // Register button
                            GlassButton(
                              label: 'Create My Account',
                              icon: Icons.arrow_forward_rounded,
                              fullWidth: true,
                              isLoading: isLoading,
                              enabled: _agreedToTerms && !isLoading,
                              onPressed: _agreedToTerms && !isLoading
                                  ? _handleRegister
                                  : null,
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
                                    'Or sign up with',
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

                            // Social signup buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialButton(
                                  icon: Icons.language_rounded,
                                  label: 'Google',
                                  onPressed: () {
                                    // Handle Google signup
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildSocialButton(
                                  icon: Icons.work_outline_rounded,
                                  label: 'LinkedIn',
                                  onPressed: () {
                                    // Handle LinkedIn signup
                                  },
                                ),
                                const SizedBox(width: 16),
                                _buildSocialButton(
                                  icon: Icons.code_rounded,
                                  label: 'GitHub',
                                  onPressed: () {
                                    // Handle GitHub signup
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Login link
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppConstants.textSecondary,
                                  ),
                                  children: [
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () => context.go('/login'),
                                        child: Text(
                                          'Sign in here',
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

  Widget _buildProfessionDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profession',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(64), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Select your profession',
                  style: TextStyle(
                    color: AppConstants.textSecondary.withAlpha(128),
                  ),
                ),
              ),
              value: _professionController.text.isEmpty
                  ? null
                  : _professionController.text,
              onChanged: (value) {
                setState(() => _professionController.text = value ?? '');
              },
              items:
                  [
                        'Graphic Designer',
                        'UI/UX Designer',
                        'Web Developer',
                        'Mobile Developer',
                        'Photographer',
                        'Videographer',
                        'Copywriter',
                        'Digital Marketer',
                        'Other',
                      ]
                      .map(
                        (profession) => DropdownMenuItem<String>(
                          value: profession,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(profession),
                          ),
                        ),
                      )
                      .toList(),
              padding: EdgeInsets.zero,
              icon: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.expand_more_rounded,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() => _agreedToTerms = !_agreedToTerms);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: _agreedToTerms
                  ? AppConstants.primaryColor
                  : Colors.white.withAlpha(40),
              border: Border.all(
                color: _agreedToTerms
                    ? AppConstants.primaryColor
                    : Colors.white.withAlpha(80),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: _agreedToTerms
                ? const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppConstants.textSecondary,
                  height: 1.5,
                ),
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to terms
                      },
                      child: Text(
                        'Terms of Service',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  TextSpan(text: ' and '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to privacy
                      },
                      child: Text(
                        'Privacy Policy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          height: 1.5,
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
