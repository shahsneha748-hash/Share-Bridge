import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/repo/user_repo.dart';
import 'package:sharebridge/service/notification_service.dart';
import '../model/notification_model.dart';
import '../repo/notification_repo.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepo _repo;
  final UserRepo _userRepo;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;


  // for unread count
  int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  NotificationViewModel({
    required NotificationRepo repo,
    required UserRepo userRepo,
  })  : _repo = repo,
        _userRepo = userRepo {
    // Listen to Firestore stream for current user
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _repo.getNotifications(uid).listen((list) {
        _notifications = list;
      });
    }
  }
  Future<String> getReceiverName(String receiverId) async {
    return await _userRepo.getReceiverName(receiverId);
  }

  bool isLoading = false;
  String? error;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    error = value;
    notifyListeners();
  }


  /// Request permission
  Future<void> requestPermission() async {
    try {
      await _repo.requestPermission();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    try {
      return await _repo.getFcmToken();
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Send push notification
  Future<bool> sendPushNotification({
    required String deviceToken,
    required NotificationModel notification,
    required String projectId,
    required String serviceAccountPath,
  }) async {
    _setLoading(true);
    try {
      return await _repo.sendPushNotification(
        deviceToken: deviceToken,
        notification: notification,
        projectId: projectId,
        serviceAccountPath: serviceAccountPath,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add notification
  Future<bool> addNotification(NotificationModel model) async {
    _setLoading(true);
    try {
      final success = await _repo.addNotification(model);

      if (success) {
        // update local list immediately so badge shows instantly
        _notifications.add(model);
        notifyListeners();
      }

      return success; // return after updating
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Stream notifications for a user
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data()))
        .toList());
  }


  /// Get notifications by user
  Future<void> fetchNotificationsByUser(String userId) async {
    _setLoading(true);
    try {
      _notifications = await _repo.getNotificationsByUser(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get notifications by type
  Future<void> fetchNotificationsByType(String type) async {
    _setLoading(true);
    try {
      _notifications = await _repo.getNotificationsByType(type);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Get single notification
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      return await _repo.getNotificationById(id);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Edit notification
  Future<void> editNotification(NotificationModel notification) async {
    try {
      await _repo.editNotification(notification);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      await _repo.deleteNotification(id);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Mark as read
  Future<void> markAllAsRead() async {
    try {
      // Update all unread notifications in Firestore
      final batch = FirebaseFirestore.instance.batch();
      for (var n in _notifications.where((n) => !n.isRead)) {
        final docRef = FirebaseFirestore.instance.collection("notifications").doc(n.id);
        batch.update(docRef, {"isRead": true});
      }
      await batch.commit();

      // Update local list immediately
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      // handle error
    }
  }


  /// Send notification to user (wrapper)
  Future<void> sendNotificationToUser(
      BuildContext context, String token, String title, String body) async {
    try {
      final model = NotificationModel(
        id: "",
        senderId: FirebaseAuth.instance.currentUser?.uid ?? "unknown",
        receiverId: "receiverId", // replace with actual receiver
        title: title,
        body: body,
        type: "request",
        createdAt: DateTime.now(),
        isRead: false,
      );

      // Save to Firestore
      await _repo.addNotification(model);

      // Send push via FCM
      await _repo.sendNotificationToUser(token, title, body);

      // Show local popup immediately
      await NotificationService.display(
        title: title,
        body: body,
        payload: "notification_screen",
        buildContext: context,
      );
    } catch (e) {
      _setError(e.toString());
    }
  }
}
