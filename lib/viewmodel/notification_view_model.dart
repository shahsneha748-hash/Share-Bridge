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
    return _notifications.where((n) => now.difference(n.createdAt).inDays < 30).toList();
  }

  int get unreadCount {
    if (_loading) return _notifications.where((n) => !n.isRead).length;
    return _notifications.where((n) => !n.isRead).length;
  }

  String? _senderProfilePicture;
  String? get senderProfilePicture => _senderProfilePicture;

  Map<String, List<NotificationModel>> groupNotifications() {
    final now = DateTime.now();
    final Map<String, List<NotificationModel>> grouped = {
      "Urgent": [],
      "Today": [],
      "PastDates": [],
    };

    for (var n in notifications) {
      final diff = now.difference(n.createdAt);

      if (n.type == "alert") {
        if (diff.inHours < 24) {
          grouped["Urgent"]!.add(n);
        } else {
          grouped["PastDates"]!.add(n); // normal alert reminder
        }
      } else {
        if (diff.inDays == 0) {
          grouped["Today"]!.add(n);
        } else if (diff.inDays <= 30) {
          grouped["PastDates"]!.add(n);
        }
      }
    }

    return grouped;
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

  Future<void> loadSenderProfilePicture() async {
    try {
      final senderId = FirebaseAuth.instance.currentUser?.uid;
      if (senderId == null) {
        setError("No logged-in user");
        return;
      }

      // Fetch from UserRepo (Firestore)
      final pic = await _userRepo.getProfilePicture(senderId);

      // Fallback to default asset if null
      _senderProfilePicture = pic ?? "assets/images/default_avatar.png";

      notifyListeners(); // so UI can rebuild if needed
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> sendNotification(String action, String receiverId) async {
    try {
      setLoading(true);
      setError(null);

      // Current logged-in user is the sender
      final senderId = FirebaseAuth.instance.currentUser?.uid;

      if (senderId == null) {
        setError("No logged-in user");
        return;
      }

      // 👇 Fetch sender’s profile picture from UserRepo (stored in Firestore)
      final senderProfilePic = await _userRepo.getProfilePicture(senderId);

      // Build notification model based on action
      final model = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        receiverId: receiverId,
        type: "alert", // accept/reject are alerts for the receiver
        title: action == "accepted"
            ? "Request Accepted"
            : "Request Rejected",
        body: action == "accepted"
            ? "Donor has accepted your donation request."
            : "Donor has rejected your donation request.",
        createdAt: DateTime.now(),
        isRead: false,
        profilePicture: senderProfilePicture,
      );

      // Save to Firestore
      final success = await _repo.addNotification(model);
      if (success) {
        _notifications.add(model);
        notifyListeners();
      }

      // Get receiver’s FCM token
      final token = await _repo.getFcmTokenForUser(receiverId);
      if (token != null) {
        await _repo.sendPushNotification(
          deviceToken: token,
          notification: model,
          projectId: "your-firebase-project-id",
          serviceAccountPath: "path/to/serviceAccount.json",
        );
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> markAsRead(String id) async{
    try {
      await _repo.markAsRead(id);
    } catch (e) {
      setError(e.toString());
    }
  }



}

