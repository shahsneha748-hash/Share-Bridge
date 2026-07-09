import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/repo/user_repo.dart';
import '../model/notification_model.dart';
import '../model/user_model.dart';
import '../repo/notification_repo.dart';
import 'package:sharebridge/service/expiry_alert_service.dart';

enum VolunteerDecision {
  none,
  request_accepted,
  request_rejected,
}

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepo _repo;
  final UserRepo _userRepo;
  final Map<String, VolunteerDecision> _decisions = {};

  VolunteerDecision getDecision(String notificationId) {
    return _decisions[notificationId] ?? VolunteerDecision.none;
  }


  NotificationViewModel({
    required NotificationRepo repo,
    required UserRepo userRepo,
  })  : _repo = repo,
        _userRepo = userRepo {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      ExpiryAlertService.checkAndCreateAlerts(uid);
      _repo.getNotifications(uid).listen(
            (list) {
          _notifications = list;
          notifyListeners();
        },
        onError: (e) {
          debugPrint('Notification stream error: $e');
          setError(e.toString());
        },
      );
    }
  }

  String? _error;
  String? get error => _error;

  bool _loading = false;
  bool get loading => _loading;

  NotificationModel? _notification;
  NotificationModel? get notification => _notification;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  List<NotificationModel> get recentNotifications {
    final now = DateTime.now();
    return _notifications.where((n) => now.difference(n.createdAt).inDays < 30).toList();
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  String? _senderProfilePicture;
  String? get senderProfilePicture => _senderProfilePicture;

  Map<String, List<NotificationModel>> groupNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = {
      "Urgent": <NotificationModel>[],
      "Today": <NotificationModel>[],
      "Yesterday": <NotificationModel>[],
    };

    for (var n in _notifications) {
      final created = n.createdAt;
      final age = now.difference(created);


      if (n.type == NotificationType.alert) {
        if (age.inDays < 1) {
          grouped["Urgent"]!.add(n);
        }
      } else {
        if (age.inDays < 30) {
          if (created.isAfter(today)) {
            grouped["Today"]!.add(n);
          } else if (created.isAfter(yesterday) && created.isBefore(today)) {
            grouped["Yesterday"]!.add(n);
          } else {
            final key =
                "${created.day} ${_monthName(created.month)} ${created.year}";
            grouped.putIfAbsent(key, () => []);
            grouped[key]!.add(n);
          }
        }
      }
    }


    for (var section in grouped.keys) {
      grouped[section]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return grouped;
  }


  String _monthName(int month) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return months[month - 1];
  }



  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<UserModel> getUserById(String uid) async {
    return await _userRepo.getUserById(uid);
  }

  Future<void> updateNotificationType(String id, NotificationType newType) async {
    try {
      final typeString = newType.toString().split('.').last;
      await _repo.updateType(id, typeString);

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final current = _notifications[index];

        _notifications[index] = current.copyWith(
          type: newType,
          isRead: false,
          body: newType == NotificationType.request_accepted
              ? "Donor has accepted your donation request."
              : newType == NotificationType.request_rejected
              ? "Donor has rejected your donation request."
              : current.body ?? "",
        );
      }
    } catch (e) {
      setError(e.toString());
    }
  }


  Future<String> getReceiverName(String receiverId) async {
    return await _userRepo.getReceiverName(receiverId);
  }

  Future<void> requestPermission() async {
    try {
      await _repo.requestPermission();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<String?> getFcmToken(String uid) async {
    try {
      return await _repo.getFcmToken(uid);
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

  Future<void> fetchNotificationsByType(NotificationType type) async {
    setLoading(true);
    try {
      final typeString = type.toString().split('.').last;
      _notifications = await _repo.getNotificationsByType(typeString);
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
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setError("No user logged in");
        return;
      }
      await _repo.markAllAsRead(uid);
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<void> getAllNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await ExpiryAlertService.checkAndCreateAlerts(uid);
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
      final pic = await _userRepo.getProfilePicture(senderId);
      _senderProfilePicture = pic ?? "assets/images/default_avatar.png";
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }
  Future<bool> sendNotification(NotificationModel model) async {
    try {
      setLoading(true);
      setError(null);

      final success = await _repo.addNotification(model);

      final token = await _repo.getFcmToken(model.receiverId);
      if (token != null) {
        await _repo.sendPushNotification(
          deviceToken: token,
          notification: model,
          projectId: "your-firebase-project-id",
          serviceAccountPath: "path/to/serviceAccount.json",
        );
      }

      return success;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }


  Future<void> markAsRead(String id) async {
    try {
      await _repo.markAsRead(id);

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final current = _notifications[index];
        if (!current.isRead) {
          _notifications[index] = current.copyWith(isRead: true);
          notifyListeners();
        }
      }
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<bool> acceptVolunteer(NotificationModel notification) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final senderInfo = await getUserById(currentUid);

    final acceptNotification = notification.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUid,
      senderName: senderInfo.fullName,
      type: NotificationType.request_accepted,
      body: "${senderInfo.fullName} has accepted your volunteering request for donation delivery.",
      createdAt: DateTime.now(),
      isRead: false,
      receiverId: notification.senderId,
    );

    final success = await sendNotification(acceptNotification);
    if (success) {
      _decisions[notification.id] = VolunteerDecision.request_accepted;
      notifyListeners();
    }
    return success;
  }

  Future<bool> rejectVolunteer(NotificationModel notification) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final senderInfo = await getUserById(currentUid);

    final rejectNotification = notification.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUid,
      senderName: senderInfo.fullName,
      type: NotificationType.request_rejected,
      body: "${senderInfo.fullName} has rejected your volunteering request for donation delivery.",
      createdAt: DateTime.now(),
      isRead: false,
      receiverId: notification.senderId,
    );

    final success = await sendNotification(rejectNotification);
    if (success) {
      _decisions[notification.id] = VolunteerDecision.request_rejected;
      notifyListeners();
    }
    return success;
  }
}