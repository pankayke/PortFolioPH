import 'package:flutter/foundation.dart';

import 'package:portfolioph/core/services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<AppNotificationItem> _notifications = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  NotificationProvider(this._apiService);

  List<AppNotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  bool get hasUnreadNotifications => unreadCount > 0;
  int get unreadCount => _notifications.where((item) => !item.isRead).length;

  Future<void> loadNotifications({
    bool refresh = false,
    int perPage = 30,
  }) async {
    if (_isLoading && !refresh) return;
    if (_hasLoaded && !refresh && _notifications.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/notifications',
        queryParameters: {'per_page': perPage},
      );

      _notifications = _parseNotifications(response);
      _hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _error = _handleError(error);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications({int perPage = 30}) {
    return loadNotifications(refresh: true, perPage: perPage);
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((item) => item.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    try {
      await _apiService.post('/notifications/$id/read');
      _notifications = _notifications
          .map(
            (item) => item.id == id
                ? item.copyWith(isRead: true, readAt: DateTime.now())
                : item,
          )
          .toList(growable: false);
      notifyListeners();
    } catch (error) {
      _error = _handleError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    if (_notifications.isEmpty || unreadCount == 0) return;

    try {
      await _apiService.post('/notifications/read-all');
      _notifications = _notifications
          .map(
            (item) => item.isRead
                ? item
                : item.copyWith(
                    isRead: true,
                    readAt: item.readAt ?? DateTime.now(),
                  ),
          )
          .toList(growable: false);
      notifyListeners();
    } catch (error) {
      _error = _handleError(error);
      notifyListeners();
      rethrow;
    }
  }

  List<AppNotificationItem> _parseNotifications(Object? response) {
    final rawItems = switch (response) {
      List<dynamic>() => response,
      Map<String, dynamic>() =>
        response['data'] is List
            ? response['data'] as List<dynamic>
            : const <dynamic>[],
      _ => const <dynamic>[],
    };

    return rawItems
        .whereType<Map>()
        .map(
          (item) =>
              AppNotificationItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  String _handleError(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return error?.toString() ?? 'Unable to load notifications.';
  }
}

class AppNotificationItem {
  final String id;
  final String event;
  final int? applicationId;
  final int? jobId;
  final String? jobTitle;
  final String? status;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotificationItem({
    required this.id,
    required this.event,
    required this.applicationId,
    required this.jobId,
    required this.jobTitle,
    required this.status,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.readAt,
  });

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at']?.toString();
    final readAtRaw = json['read_at']?.toString();
    return AppNotificationItem(
      id: json['id']?.toString() ?? '',
      event: json['event']?.toString() ?? '',
      applicationId: _toInt(json['application_id']),
      jobId: _toInt(json['job_id']),
      jobTitle: json['job_title']?.toString(),
      status: json['status']?.toString(),
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse(createdAtRaw ?? '') ?? DateTime.now(),
      readAt: DateTime.tryParse(readAtRaw ?? ''),
    );
  }

  AppNotificationItem copyWith({bool? isRead, DateTime? readAt}) {
    return AppNotificationItem(
      id: id,
      event: event,
      applicationId: applicationId,
      jobId: jobId,
      jobTitle: jobTitle,
      status: status,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  static int? _toInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
