// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portfolioph/core/mixins/animation_mixins.dart';
import 'package:portfolioph/presentation/providers/theme_provider.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';
import 'package:portfolioph/presentation/widgets/theme_toggle_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin, BokehAnimationMixin {
  // ── Display Settings ────────────────────────────────────────────────────────
  late bool _emailNotifications;
  late bool _jobAlerts;
  late bool _applicationUpdates;
  late bool _messageNotifications;

  // ── Privacy & Visibility ────────────────────────────────────────────────────
  late bool _publicProfile;
  late bool _showPortfolioPublic;
  late bool _showSkillsPublic;
  late bool _hideEmailFromEmployers;

  // ── Job Preferences ────────────────────────────────────────────────────────
  late String? _preferredJobLocation;
  late String? _preferredJobType;
  late bool _showSalaryPublicly;

  @override
  void initState() {
    super.initState();
    initializeBokehAnimation();
    _initializeSettings();
  }

  @override
  void dispose() {
    disposeBokehAnimation();
    super.dispose();
  }

  void _initializeSettings() {
    // Initialize all settings to default values
    _emailNotifications = true;
    _jobAlerts = true;
    _applicationUpdates = true;
    _messageNotifications = true;

    _publicProfile = true;
    _showPortfolioPublic = true;
    _showSkillsPublic = true;
    _hideEmailFromEmployers = false;

    _preferredJobLocation = 'All Locations';
    _preferredJobType = 'All Types';
    _showSalaryPublicly = false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final themeMode = themeProvider.themeMode;
    final theme = Theme.of(context);

    return PremiumAppBackground(
      animation: bokehController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
          actions: const [ThemeToggleButton()],
        ),
        body: ListView(
          children: [
            const SizedBox(height: 8),

            // ══════════════════════════════════════════════════════════════════════
            // SECTION: Display & Theme
            // ══════════════════════════════════════════════════════════════════════
            _SettingsSection(
              title: 'Display & Theme',
              icon: Icons.palette_outlined,
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Theme Mode'),
                  subtitle: Text(switch (themeMode) {
                    ThemeMode.light => 'Light',
                    ThemeMode.dark => 'Dark',
                    ThemeMode.system => 'System (Follow OS)',
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        icon: Icon(Icons.phone_android_outlined),
                        label: Text('System'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) return;
                      themeProvider.setThemeMode(selection.first);
                    },
                  ),
                ),
                const Divider(height: 24),
                ListTile(
                  leading: const Icon(Icons.text_fields_outlined),
                  title: const Text('Text Size'),
                  subtitle: const Text('Normal'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showTextSizeDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.density_medium_outlined),
                  title: const Text('Display Density'),
                  subtitle: const Text('Comfortable'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showDensityDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Language'),
                  subtitle: const Text('English (US)'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showLanguageDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════════════
            // SECTION: Notifications
            // ══════════════════════════════════════════════════════════════════════
            _SettingsSection(
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              children: [
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive updates via email'),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() => _emailNotifications = value);
                    _showSnackBar(
                      'Email notifications ${value ? 'enabled' : 'disabled'}',
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Job Alerts'),
                  subtitle: const Text('Get notified about matching jobs'),
                  value: _jobAlerts,
                  onChanged: (value) {
                    setState(() => _jobAlerts = value);
                    _showSnackBar(
                      'Job alerts ${value ? 'enabled' : 'disabled'}',
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Application Updates'),
                  subtitle: const Text('Get notified about app updates'),
                  value: _applicationUpdates,
                  onChanged: (value) {
                    setState(() => _applicationUpdates = value);
                    _showSnackBar(
                      'Application updates ${value ? 'enabled' : 'disabled'}',
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Message Notifications'),
                  subtitle: const Text(
                    'Get alerts for messages from employers',
                  ),
                  value: _messageNotifications,
                  onChanged: (value) {
                    setState(() => _messageNotifications = value);
                    _showSnackBar(
                      'Message notifications ${value ? 'enabled' : 'disabled'}',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════════════
            // SECTION: Privacy & Visibility
            // ══════════════════════════════════════════════════════════════════════
            _SettingsSection(
              title: 'Privacy & Visibility',
              icon: Icons.privacy_tip_outlined,
              children: [
                SwitchListTile(
                  title: const Text('Public Profile'),
                  subtitle: const Text('Allow employers to find your profile'),
                  value: _publicProfile,
                  onChanged: (value) {
                    setState(() => _publicProfile = value);
                    _showSnackBar(
                      'Profile visibility ${value ? 'public' : 'private'}',
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Show Portfolio Publicly'),
                  subtitle: const Text(
                    'Allow public viewing of your portfolio',
                  ),
                  value: _showPortfolioPublic,
                  onChanged: _publicProfile
                      ? (value) {
                          setState(() => _showPortfolioPublic = value);
                          _showSnackBar(
                            'Portfolio ${value ? 'public' : 'private'}',
                          );
                        }
                      : null,
                ),
                SwitchListTile(
                  title: const Text('Show Skills Publicly'),
                  subtitle: const Text('Display your skills to employers'),
                  value: _showSkillsPublic,
                  onChanged: _publicProfile
                      ? (value) {
                          setState(() => _showSkillsPublic = value);
                          _showSnackBar(
                            'Skills ${value ? 'visible' : 'hidden'}',
                          );
                        }
                      : null,
                ),
                SwitchListTile(
                  title: const Text('Hide Email from Employers'),
                  subtitle: const Text(
                    'They\'ll use the message system instead',
                  ),
                  value: _hideEmailFromEmployers,
                  onChanged: (value) {
                    setState(() => _hideEmailFromEmployers = value);
                    _showSnackBar(
                      'Email ${value ? 'hidden' : 'visible'} to employers',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════════════
            // SECTION: Job Preferences
            // ══════════════════════════════════════════════════════════════════════
            _SettingsSection(
              title: 'Job Preferences',
              icon: Icons.business_center_outlined,
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Preferred Location'),
                  subtitle: Text(_preferredJobLocation ?? 'All Locations'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showLocationDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.work_history_outlined),
                  title: const Text('Job Type'),
                  subtitle: Text(_preferredJobType ?? 'All Types'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showJobTypeDialog(context),
                ),
                SwitchListTile(
                  title: const Text('Show Salary Expectations'),
                  subtitle: const Text('Display your salary range publicly'),
                  value: _showSalaryPublicly,
                  onChanged: (value) {
                    setState(() => _showSalaryPublicly = value);
                    _showSnackBar(
                      'Salary expectations ${value ? 'shown' : 'hidden'}',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════════════
            // SECTION: Account & Security
            // ══════════════════════════════════════════════════════════════════════
            _SettingsSection(
              title: 'Account & Security',
              icon: Icons.security_outlined,
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account password'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showChangePasswordDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.link_outlined),
                  title: const Text('Linked Accounts'),
                  subtitle: const Text('Google, LinkedIn, GitHub connections'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showLinkedAccountsDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined),
                  title: const Text('Export Data'),
                  subtitle: const Text(
                    'Download your profile and portfolio data',
                  ),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showSnackBar(
                    'Data export initiated. Check your email soon!',
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded),
                  title: const Text('Delete Account'),
                  subtitle: const Text('Permanently delete your account'),
                  textColor: theme.colorScheme.error,
                  iconColor: theme.colorScheme.error,
                  trailing: Icon(
                    Icons.chevron_right_outlined,
                    color: theme.colorScheme.error,
                  ),
                  onTap: () => _showDeleteAccountDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════════════
            // SECTION: Help & Support
            // ══════════════════════════════════════════════════════════════════════
            _SettingsSection(
              title: 'Help & Support',
              icon: Icons.help_outline_rounded,
              children: [
                ListTile(
                  leading: const Icon(Icons.help_center_outlined),
                  title: const Text('Help Center'),
                  subtitle: const Text('Browse FAQs and guides'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showHelpCenterDialog(context),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Report a Bug'),
                  subtitle: const Text('Found an issue? Let us know'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showFeedbackDialog(context, isBug: true),
                ),
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Send Feedback'),
                  subtitle: const Text('Share your ideas and suggestions'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showFeedbackDialog(context, isBug: false),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  subtitle: const Text('Read our terms and conditions'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showSnackBar('Opening Terms of Service'),
                ),
                ListTile(
                  leading: const Icon(Icons.policy_outlined),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('How we protect your data'),
                  trailing: const Icon(Icons.chevron_right_outlined),
                  onTap: () => _showSnackBar('Opening Privacy Policy'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════════════
            // SECTION: About App
            // ══════════════════════════════════════════════════════════════════════
            _SettingsSection(
              title: 'About',
              icon: Icons.info_outline_rounded,
              children: [
                ListTile(
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0 (Build 2026.03.20)'),
                ),
                ListTile(
                  title: const Text('Developer'),
                  subtitle: const Text('PortFolioPH Team'),
                ),
                ListTile(
                  title: const Text('Website'),
                  subtitle: const Text('www.portfolioph.com'),
                  onTap: () => _showSnackBar('Opening website'),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Dialog Builders
  // ──────────────────────────────────────────────────────────────────────────

  void _showTextSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Small', 'Normal', 'Large', 'Extra Large']
              .map(
                (size) => RadioListTile<String>(
                  title: Text(size),
                  value: size,
                  groupValue: 'Normal',
                  onChanged: (_) {
                    Navigator.pop(context);
                    _showSnackBar('Text size changed to $size');
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showDensityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Display Density'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Compact', 'Comfortable', 'Spacious']
              .map(
                (density) => RadioListTile<String>(
                  title: Text(density),
                  value: density,
                  groupValue: 'Comfortable',
                  onChanged: (_) {
                    Navigator.pop(context);
                    _showSnackBar('Density changed to $density');
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English (US)', 'Filipino', 'Spanish']
              .map(
                (lang) => RadioListTile<String>(
                  title: Text(lang),
                  value: lang,
                  groupValue: 'English (US)',
                  onChanged: (_) {
                    Navigator.pop(context);
                    _showSnackBar('Language changed to $_preferredJobLocation');
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preferred Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              [
                    'All Locations',
                    'Metro Manila',
                    'Cebu',
                    'Davao',
                    'Baguio',
                    'Iloilo',
                  ]
                  .map(
                    (location) => RadioListTile<String>(
                      title: Text(location),
                      value: location,
                      groupValue: _preferredJobLocation,
                      onChanged: (value) {
                        Navigator.pop(context);
                        setState(() => _preferredJobLocation = value);
                        _showSnackBar('Location preference updated');
                      },
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  void _showJobTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Job Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              [
                    'All Types',
                    'Full-time',
                    'Part-time',
                    'Contract',
                    'Freelance',
                    'Internship',
                  ]
                  .map(
                    (type) => RadioListTile<String>(
                      title: Text(type),
                      value: type,
                      groupValue: _preferredJobType,
                      onChanged: (value) {
                        Navigator.pop(context);
                        setState(() => _preferredJobType = value);
                        _showSnackBar('Job type preference updated');
                      },
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Password changed successfully!');
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLinkedAccountsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Linked Accounts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Google'),
              subtitle: const Text('Not linked'),
              trailing: FilledButton(
                onPressed: () => _showSnackBar('Linking Google account...'),
                child: const Text('Link'),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('LinkedIn'),
              subtitle: const Text('Not linked'),
              trailing: FilledButton(
                onPressed: () => _showSnackBar('Linking LinkedIn account...'),
                child: const Text('Link'),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code_outlined),
              title: const Text('GitHub'),
              subtitle: const Text('Not linked'),
              trailing: FilledButton(
                onPressed: () => _showSnackBar('Linking GitHub account...'),
                child: const Text('Link'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, {required bool isBug}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBug ? 'Report a Bug' : 'Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: isBug ? 'Describe the issue' : 'Share your feedback',
                border: const OutlineInputBorder(),
                hintText: 'Please be as detailed as possible',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(
                isBug
                    ? 'Bug report submitted. Thank you!'
                    : 'Feedback sent. Thank you!',
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Help Center'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Reset your password from the login screen.'),
              SizedBox(height: 8),
              Text('• Use the dashboard tabs to switch roles and workflows.'),
              SizedBox(height: 8),
              Text(
                '• If a screen fails to load, pull to refresh or log out/in.',
              ),
              SizedBox(height: 8),
              Text('• For support, file a bug report from this screen.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. Your profile, portfolio, and all data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Account deletion initiated');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Settings Section Widget
// ────────────────────────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
          child: Column(
            children: List.generate(
              children.length,
              (index) => Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
