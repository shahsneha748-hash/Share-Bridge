import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../repo/admin_notification_repo.dart';
import '../repo/admin_notification_repo_impl.dart';

class AdminNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day ago';
  }

  factory AdminNotification.fromMap(Map<String, dynamic> map) {
    return AdminNotification(
      id:        map['id'] as String? ?? '',
      type:      map['type'] as String? ?? '',
      title:     map['title'] as String? ?? '',
      body:      map['body'] as String? ?? '',
      isRead:    map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class AdminNotificationViewModel extends ChangeNotifier {
  final AdminNotificationRepo _repo = AdminNotificationRepoImpl();

  List<AdminNotification> _notifications = [];
  bool isLoading = false;

  List<AdminNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _repo.fetchNotifications();
      _notifications = data.map(AdminNotification.fromMap).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = AdminNotification(
        id:        _notifications[index].id,
        type:      _notifications[index].type,
        title:     _notifications[index].title,
        body:      _notifications[index].body,
        isRead:    true,
        createdAt: _notifications[index].createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
    await fetchNotifications();
  }
}