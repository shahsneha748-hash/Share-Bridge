// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:sharebridge/model/notification_model.dart';
// import 'package:sharebridge/repo/notification_repo.dart';
//
// class NotificationViewModel extends ChangeNotifier {
//   final NotificationRepo _notificationRepo;
//
//   NotificationViewModel({required NotificationRepo notificationRepo})
//       : _notificationRepo = notificationRepo;
//
//   String? _error;
//   String? get error => _error;
//
//   bool _loading = false;
//   bool get loading => _loading;
//
//   List<NotificationModel>? _notifications;
//   List<NotificationModel>? get notifications => _notifications;
//
//   NotificationModel? _selectedNotification;
//   NotificationModel? get selectedNotification => _selectedNotification;
//
//   void setError(String? error) {
//     _error = error;
//     notifyListeners();
//   }
//
//   void setLoading(bool value) {
//     _loading = value;
//     notifyListeners();
//   }
//
//   // 🔹 NEW: unread count
//   int get unreadCount {
//     if (_notifications == null) return 0;
//     return _notifications!.where((n) => !n.isRead).length;
//   }
//
//   // 🔹 NEW: Permission init
//   Future<void> initNotifications() async {
//     setLoading(true);
//     setError(null);
//     try {
//       final settings = await _notificationRepo.requestPermission();
//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         print("Permission granted");
//       } else {
//         print("Permission denied");
//       }
//     } catch (e) {
//       setError(e.toString());
//     } finally {
//       setLoading(false);
//     }
//   }
//
//   // 🔹 NEW: Show token
//   Future<void> showToken() async {
//     setLoading(true);
//     setError(null);
//     try {
//       final token = await _notificationRepo.getFcmToken();
//       print("FCM Token: $token");
//     } catch (e) {
//       setError(e.toString());
//     } finally {
//       setLoading(false);
//     }
//   }
//
//   // 🔹 NEW: Send notification
//   Future<void> sendNotification(String deviceToken) async {
//     setLoading(true);
//     setError(null);
//     try {
//       final notification = NotificationModel(
//         userId: "testUser123",          // replace with actual user ID
//         type: "test",                   // e.g. "reminder"
//         title: "Hello",
//         body: "This is a test",
//         message: "This is a test message",
//         timestamp: DateTime.now(),      // current time
//         isRead: false,                  // new notifications are unread
//       );
//
//       final success = await _notificationRepo.sendPushNotification(
//         deviceToken: deviceToken,
//         notification: notification,
//         projectId: dotenv.env['PROJECT_ID']!,
//         serviceAccountPath: dotenv.env['PATH_TO_SECRET']!,
//       );
//
//       print(success != null? "Notification sent" : "Notification failed");
//     } catch (e) {
//       setError(e.toString());
//     } finally {
//       setLoading(false);
//     }
//   }
//   // CREATE
//   Future<bool> addNotification(NotificationModel notification) async {
//     setLoading(true);
//     setError(null);
//     try {
//       await _notificationRepo.addNotification(notification);
//       return true;
//     } on Exception catch (e) {
//       setError(e.toString());
//       return false;
//     } finally {
//       setLoading(false);
//     }
//   }
//
//   // READ (all by user)
//   Future<void> getNotificationsByUser(String userId) async {
//     setLoading(true);
//     setError(null);
//     try {
//       _notifications = await _notificationRepo.getNotificationsByUser(userId);
//     } on Exception catch (e) {
//       setError(e.toString());
//     } finally {
//       setLoading(false);
//     }
//   }
//
//   // READ (by type)
//   Future<void> getNotificationsByType(String type) async {
//     setLoading(true);
//     setError(null);
//     try {
//       _notifications = await _notificationRepo.getNotificationsByType(type);
//     } on Exception catch (e) {
//       setError(e.toString());
//     } finally {
//       setLoading(false);
//     }
//   }
//
//   // READ (single notification)
//   Future<void> getNotificationById(String id) async {
//     setLoading(true);
//     setError(null);
//     try {
//       _selectedNotification = await _notificationRepo.getNotificationById(id);
//     } on Exception catch (e) {
//       setError(e.toString());
//     } finally {
//       setLoading(false);
//     }
//   }
//
//   // UPDATE (edit notification)
//   Future<bool> editNotification(NotificationModel notification) async {
//     setLoading(true);
//     setError(null);
//     try {
//       await _notificationRepo.editNotification(notification);
//       return true;
//     } on Exception catch (e) {
//       setError(e.toString());
//       return false;
//     } finally {
//       setLoading(false);
//     }
//   }
//
//
//   // Group notifications by time buckets
//   Map<String, List<NotificationModel>> groupNotifications() {
//     final now = DateTime.now();
//     final today = <NotificationModel>[];
//     final yesterday = <NotificationModel>[];
//     final thisWeek = <NotificationModel>[];
//     final thisMonth = <NotificationModel>[];
//
//     if (_notifications == null) return {};
//
//     for (var n in _notifications!) {
//       final diff = now.difference(n.timestamp).inDays;
//
//       if (diff == 0) {
//         today.add(n);
//       } else if (diff == 1) {
//         yesterday.add(n);
//       } else if (diff <= 7) {
//         thisWeek.add(n);
//       } else if (diff <= 30) {
//         thisMonth.add(n);
//       }
//     }
//
//     return {
//       "Today": today,
//       "Yesterday": yesterday,
//       "This week": thisWeek,
//       "This month": thisMonth,
//     };
//   }
// }


import 'package:flutter/material.dart';
import '../model/notification_model.dart';
import '../repo/notification_repo.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepo _notificationRepo;
  NotificationViewModel({required NotificationRepo notificationRepo})
      : _notificationRepo = notificationRepo;

  String? _error;
  bool _loading = false;
  List<NotificationModel>? _notifications;

  String? get error => _error;
  bool get loading => _loading;
  List<NotificationModel>? get notifications => _notifications;

  void setError(String? error) { _error = error; notifyListeners(); }
  void setLoading(bool value) { _loading = value; notifyListeners(); }

  Future<void> getNotificationsByUser(String userId) async {
    setLoading(true);
    try {
      _notifications = await _notificationRepo.getNotificationsByUser(userId);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Map<String, List<NotificationModel>> groupNotifications() {
    final now = DateTime.now();
    final today = <NotificationModel>[];
    final yesterday = <NotificationModel>[];
    final thisWeek = <NotificationModel>[];
    final thisMonth = <NotificationModel>[];

    if (_notifications == null) return {};

    for (var n in _notifications!) {
      final diff = now.difference(n.timestamp).inDays;
      if (diff == 0) today.add(n);
      else if (diff == 1) yesterday.add(n);
      else if (diff <= 7) thisWeek.add(n);
      else if (diff <= 30) thisMonth.add(n);
    }

    return {
      "Today": today,
      "Yesterday": yesterday,
      "This week": thisWeek,
      "This month": thisMonth,
    };
  }
}


