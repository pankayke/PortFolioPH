// lib/presentation/screens/auth/role_selection_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Role Selection Screen – User chooses between Recruiter or Job Seeker.
//
// Shown after registration, before profile setup.
// Allows users to pick their primary role to access tailored features.
//
// Roles:
//   • Recruiter  → Post jobs, manage applications, approve candidates
//   • Seeker     → Search jobs, apply, track applications, build portfolio
//
// On selection → Store role in AuthProvider → Navigate to /profile-setup.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/router/app_router.dart';
import 'package:portfolioph/presentation/providers/auth_provider.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'What\'s Your Role?',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you want to use PortFolioPH',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),

                // Role cards
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildRoleCard(
                          icon: Icons.business,
                          title: 'Recruiter',
                          description:
                              'Post jobs, manage applications,\nand find talent',
                          role: AppConstants.roleRecruiter,
                          context: context,
                        ),
                        const SizedBox(height: 24),
                        _buildRoleCard(
                          icon: Icons.person_search,
                          title: 'Job Seeker',
                          description:
                              'Search jobs, apply easily,\nand build your portfolio',
                          role: AppConstants.roleSeeker,
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _selectedRole == null || _isProcessing
                            ? null
                            : _onContinue,
                        child: _isProcessing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Continue as ${_selectedRole == AppConstants.roleRecruiter
                                    ? 'Recruiter'
                                    : _selectedRole == AppConstants.roleSeeker
                                    ? 'Seeker'
                                    : 'Selected Role'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isProcessing ? null : _onSkipForNow,
                      child: const Text('Skip for Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String description,
    required String role,
    required BuildContext context,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: _isProcessing ? null : () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Icon(Icons.check_circle, color: Colors.white, size: 24),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    if (_selectedRole == null) return;

    setState(() => _isProcessing = true);

    try {
      // Update user role in provider
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(role: _selectedRole!);
        authProvider.updateCurrentUser(updatedUser);
      }

      // Navigate to profile setup
      if (mounted) {
        context.go(AppRoutes.profileSetup);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _onSkipForNow() {
    // Navigate to profile setup without role selection
    // Default to 'seeker' if not selected
    context.go(AppRoutes.profileSetup);
  }
}
