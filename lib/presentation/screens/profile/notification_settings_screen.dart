// lib/presentation/screens/profile/notification_settings_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Notification preferences for the user.
//
// Features:
//   • Toggle notifications for different events
//   • Email and push notification preferences
//   • Job alert frequency settings
//   • Persistent storage using SharedPreferences
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // ── Notification Preferences ───────────────────────────────────────────────
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _jobAlerts = true;
  bool _applicationUpdates = true;
  bool _messageNotifications = true;
  bool _newMatchNotifications = true;
  String _emailFrequency = 'daily'; // daily, weekly, never

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _emailNotifications = _prefs.getBool('email_notifications') ?? true;
      _pushNotifications = _prefs.getBool('push_notifications') ?? true;
      _jobAlerts = _prefs.getBool('job_alerts') ?? true;
      _applicationUpdates = _prefs.getBool('application_updates') ?? true;
      _messageNotifications = _prefs.getBool('message_notifications') ?? true;
      _newMatchNotifications = _prefs.getBool('new_match_notifications') ?? true;
      _emailFrequency = _prefs.getString('email_frequency') ?? 'daily';
      _isInitialized = true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<void> _saveFrequency(String frequency) async {
    await _prefs.setString('email_frequency', frequency);
  }

  Future<void> _showSuccessMessage(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notification Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PremiumAppBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notification Settings'),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Push Notifications Section ───────────────────────────────
              _buildSectionTitle('Push Notifications'),
              const SizedBox(height: 12),
              _buildToggleTile(
                'Enable Push Notifications',
                'Receive push notifications on your device',
                _pushNotifications,
                (value) => setState(() {
                  _pushNotifications = value;
                  _savePreference('push_notifications', value);
                  _showSuccessMessage(
                    value ? 'Push notifications enabled' : 'Push notifications disabled',
                  );
                }),
              ),
              const SizedBox(height: 24),

              // ── Email Notifications Section ──────────────────────────────
              _buildSectionTitle('Email Notifications'),
              const SizedBox(height: 12),
              _buildToggleTile(
                'Enable Email Notifications',
                'Receive important updates via email',
                _emailNotifications,
                (value) => setState(() {
                  _emailNotifications = value;
                  _savePreference('email_notifications', value);
                  _showSuccessMessage(
                    value ? 'Email notifications enabled' : 'Email notifications disabled',
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Email frequency dropdown
              if (_emailNotifications)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email Frequency',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      DropdownButton<String>(
                        value: _emailFrequency,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'daily',
                            child: Text('Daily'),
                          ),
                          DropdownMenuItem(
                            value: 'weekly',
                            child: Text('Weekly'),
                          ),
                          DropdownMenuItem(
                            value: 'never',
                            child: Text('Never'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _emailFrequency = value;
                              _saveFrequency(value);
                              _showSuccessMessage(
                                'Email frequency updated to ${value.capitalize()}',
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // ── Job-Related Notifications ────────────────────────────────
              _buildSectionTitle('Job Notifications'),
              const SizedBox(height: 12),
              _buildToggleTile(
                'Job Alerts',
                'Get notified about new jobs matching your profile',
                _jobAlerts,
                (value) => setState(() {
                  _jobAlerts = value;
                  _savePreference('job_alerts', value);
                  _showSuccessMessage(
                    value ? 'Job alerts enabled' : 'Job alerts disabled',
                  );
                }),
              ),
              const SizedBox(height: 12),
              _buildToggleTile(
                'New Job Matches',
                'Notifications for newly matched job opportunities',
                _newMatchNotifications,
                (value) => setState(() {
                  _newMatchNotifications = value;
                  _savePreference('new_match_notifications', value);
                  _showSuccessMessage(
                    value
                        ? 'New job match notifications enabled'
                        : 'New job match notifications disabled',
                  );
                }),
              ),
              const SizedBox(height: 24),

              // ── Application Notifications ────────────────────────────────
              _buildSectionTitle('Application Notifications'),
              const SizedBox(height: 12),
              _buildToggleTile(
                'Application Updates',
                'Get notified when application status changes',
                _applicationUpdates,
                (value) => setState(() {
                  _applicationUpdates = value;
                  _savePreference('application_updates', value);
                  _showSuccessMessage(
                    value
                        ? 'Application update notifications enabled'
                        : 'Application update notifications disabled',
                  );
                }),
              ),
              const SizedBox(height: 12),
              _buildToggleTile(
                'Messages',
                'Get notified about new messages from recruiters',
                _messageNotifications,
                (value) => setState(() {
                  _messageNotifications = value;
                  _savePreference('message_notifications', value);
                  _showSuccessMessage(
                    value
                        ? 'Message notifications enabled'
                        : 'Message notifications disabled',
                  );
                }),
              ),
              const SizedBox(height: 24),

              // ── Notification Digest ─────────────────────────────────────
              _buildSectionTitle('Notification Digest'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildDigestItem(
                      'Email Notifications: ${_emailNotifications ? 'Enabled' : 'Disabled'}',
                    ),
                    _buildDigestItem(
                      'Push Notifications: ${_pushNotifications ? 'Enabled' : 'Disabled'}',
                    ),
                    _buildDigestItem(
                      'Active Alerts: ${_buildActiveAlertCount()}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Reset Button ────────────────────────────────────────────
              FilledButton.tonal(
                onPressed: () => _showResetDialog(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restart_alt, size: 18),
                    const SizedBox(width: 8),
                    const Text('Reset to Defaults'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDigestItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  String _buildActiveAlertCount() {
    int count = 0;
    if (_jobAlerts) count++;
    if (_applicationUpdates) count++;
    if (_messageNotifications) count++;
    if (_newMatchNotifications) count++;
    return '$count active';
  }

  Future<void> _showResetDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults?'),
        content: const Text(
          'This will restore all notification settings to their default values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _emailNotifications = true;
      _pushNotifications = true;
      _jobAlerts = true;
      _applicationUpdates = true;
      _messageNotifications = true;
      _newMatchNotifications = true;
      _emailFrequency = 'daily';
    });

    await _prefs.setBool('email_notifications', true);
    await _prefs.setBool('push_notifications', true);
    await _prefs.setBool('job_alerts', true);
    await _prefs.setBool('application_updates', true);
    await _prefs.setBool('message_notifications', true);
    await _prefs.setBool('new_match_notifications', true);
    await _prefs.setString('email_frequency', 'daily');

    await _showSuccessMessage('Settings reset to defaults');
  }
}

extension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
