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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:portfolioph/core/constants/app_constants.dart';
import 'package:portfolioph/core/services/api_service.dart';
import 'package:portfolioph/presentation/widgets/premium_app_background.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
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
  bool _isLoadingNotificationFeed = true;
  bool _isMarkingAllRead = false;
  String? _notificationFeedError;
  List<_UserNotificationItem> _notificationFeed = const [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadNotificationFeed();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _emailNotifications = _prefs.getBool('email_notifications') ?? true;
      _pushNotifications = _prefs.getBool('push_notifications') ?? true;
      _jobAlerts = _prefs.getBool('job_alerts') ?? true;
      _applicationUpdates = _prefs.getBool('application_updates') ?? true;
      _messageNotifications = _prefs.getBool('message_notifications') ?? true;
      _newMatchNotifications =
          _prefs.getBool('new_match_notifications') ?? true;
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
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _loadNotificationFeed() async {
    setState(() {
      _isLoadingNotificationFeed = true;
      _notificationFeedError = null;
    });

    try {
      final response = await context.read<ApiService>().get(
        '/notifications',
        queryParameters: {'per_page': 30},
      );

      final rawItems = response is List ? response : const <dynamic>[];
      final notifications = rawItems
          .whereType<Map>()
          .map(
            (item) => _UserNotificationItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _notificationFeed = notifications;
        _isLoadingNotificationFeed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _notificationFeedError =
            'Could not load notifications right now. Pull to retry later.';
        _isLoadingNotificationFeed = false;
      });
    }
  }

  Future<void> _markNotificationAsRead(String id) async {
    final targetIndex = _notificationFeed.indexWhere((item) => item.id == id);
    if (targetIndex == -1 || _notificationFeed[targetIndex].isRead) return;

    try {
      await context.read<ApiService>().post('/notifications/$id/read');
      if (!mounted) return;
      setState(() {
        _notificationFeed = _notificationFeed
            .map(
              (item) => item.id == id
                  ? item.copyWith(
                      isRead: true,
                      readAt: DateTime.now(),
                    )
                  : item,
            )
            .toList(growable: false);
      });
    } catch (_) {
      if (!mounted) return;
      _showSuccessMessage('Unable to mark notification as read.');
    }
  }

  Future<void> _markAllNotificationsAsRead() async {
    if (_isMarkingAllRead) return;

    setState(() => _isMarkingAllRead = true);
    try {
      await context.read<ApiService>().post('/notifications/read-all');
      if (!mounted) return;
      setState(() {
        _notificationFeed = _notificationFeed
            .map(
              (item) => item.copyWith(
                isRead: true,
                readAt: item.readAt ?? DateTime.now(),
              ),
            )
            .toList(growable: false);
      });
      _showSuccessMessage('All notifications marked as read');
    } catch (_) {
      if (!mounted) return;
      _showSuccessMessage('Unable to mark all notifications as read.');
    } finally {
      if (mounted) {
        setState(() => _isMarkingAllRead = false);
      }
    }
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
              // ── Recent Application Updates ───────────────────────────────
              _buildSectionTitle('Recent Application Updates'),
              const SizedBox(height: 12),
              if (_isLoadingNotificationFeed)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_notificationFeedError != null)
                Container(
                  width: double.infinity,
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
                        _notificationFeedError!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: _loadNotificationFeed,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_notificationFeed.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('No recent application updates yet.'),
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _isMarkingAllRead
                              ? null
                              : _markAllNotificationsAsRead,
                          icon: _isMarkingAllRead
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.done_all),
                          label: const Text('Mark all read'),
                        ),
                      ],
                    ),
                    ..._notificationFeed.map(_buildNotificationCard),
                  ],
                ),
              const SizedBox(height: 24),

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
                    value
                        ? 'Push notifications enabled'
                        : 'Push notifications disabled',
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
                    value
                        ? 'Email notifications enabled'
                        : 'Email notifications disabled',
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
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                Text(title, style: Theme.of(context).textTheme.labelLarge),
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
          Switch.adaptive(value: value, onChanged: onChanged),
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

  Widget _buildNotificationCard(_UserNotificationItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _markNotificationAsRead(item.id),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.isRead
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.status == 'accepted'
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                size: 20,
                color: item.status == 'accepted'
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTimestamp(item.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
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

class _UserNotificationItem {
  final String id;
  final String title;
  final String message;
  final String status;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const _UserNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.status,
    required this.isRead,
    required this.createdAt,
    required this.readAt,
  });

  factory _UserNotificationItem.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at']?.toString();
    final readAtRaw = json['read_at']?.toString();
    return _UserNotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Application update',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now(),
      readAt: DateTime.tryParse(readAtRaw ?? ''),
    );
  }

  _UserNotificationItem copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return _UserNotificationItem(
      id: id,
      title: title,
      message: message,
      status: status,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
