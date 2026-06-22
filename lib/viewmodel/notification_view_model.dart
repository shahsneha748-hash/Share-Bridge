import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/repo/user_repo.dart';
import '../model/notification_model.dart';
import '../repo/notification_repo.dart';


class NotificationViewModel extends ChangeNotifier {
  final NotificationRepo _repo;
  final UserRepo _userRepo;

  NotificationViewModel({
    required NotificationRepo repo,
    required UserRepo userRepo,
  })  : _repo = repo,
        _userRepo = userRepo {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _repo.getNotifications(uid).listen((list) {
        _notifications = list;
        notifyListeners();
      });
    }
  }

  // State
  String? _error;
  String? get error => _error;

  bool _loading = false;
  bool get loading => _loading;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  // Only show notifications newer than 30 days
  List<NotificationModel> get recentNotifications {
    if (_loading) return _notifications; // keep last state until Firestore updates
    final now = DateTime.now();
    return _notifications.where((n) {
      final age = now.difference(n.createdAt);
      return age.inDays < 30; // only show if less than 30 days old
    }).toList();
  }

  int get unreadCount {
    if (_loading) return _notifications.where((n) => !n.isRead).length;
    return _notifications.where((n) => !n.isRead).length;
  }

  // Helpers
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<String> getReceiverName(String receiverId) async {
    return await _userRepo.getReceiverName(receiverId);
  }

  // Actions (delegated to repo)
  Future<void> requestPermission() async {
    try {
      await _repo.requestPermission();
    } catch (e) {
      setError(e.toString());
    }
  }

Future<String?> getFcmToken() async {
    try {
      return await _repo.getFcmToken();
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }

  Future<bool> sendPushNotification({
    required String deviceToken,
    required NotificationModel notification,
    required String projectId,
    required String serviceAccountPath,
  }) async {
    setLoading(true);
    try {
      return await _repo.sendPushNotification(
        deviceToken: deviceToken,
        notification: notification,
        projectId: projectId,
        serviceAccountPath: serviceAccountPath,
      );
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> addNotification(NotificationModel model) async {
    setLoading(true);
    setError(null);
    try {
      final success = await _repo.addNotification(model);
      if (success) {
        _notifications.add(model);
        notifyListeners();
      }
      return success;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchNotificationsByUser(String userId) async {
    setLoading(true);
    try {
      _notifications = await _repo.getNotificationsByUser(userId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchNotificationsByType(String type) async {
    setLoading(true);
    try {
      _notifications = await _repo.getNotificationsByType(type);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      return await _repo.getNotificationById(id);
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }

  Future<void> editNotification(NotificationModel notification) async {
    try {
      await _repo.editNotification(notification);
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repo.deleteNotification(id);
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // Get current user ID
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setError("No user logged in");
        return;
      }
      // Call repo to mark all as read in Firestore
      await _repo.markAllAsRead(uid);

      // Update local list so unreadCount becomes 0 immediately
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();

      // Notify UI to rebuild (badge will disappear)
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> getAllNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await fetchNotificationsByUser(uid);
    }
  }


}

