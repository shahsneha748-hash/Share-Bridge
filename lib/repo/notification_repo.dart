import 'package:sharebridge/model/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sharebridge/model/notification_model.dart';

abstract class NotificationRepo {
  // Firebase Messaging permissions
  Future<NotificationSettings> requestPermission();

  // Get FCM token
  Future<String?> getFcmToken();

  // Send push notification
  Future<bool> sendPushNotification({
    required String deviceToken,
    required NotificationModel notification,
    required String projectId,
    required String serviceAccountPath,
  });

  Stream<List<NotificationModel>> getNotifications(String userId);

  // CRUD operations with Firestore
  Future<bool> addNotification(NotificationModel notification);

  Future<List<NotificationModel>> getNotificationsByUser(String userId);

  Future<List<NotificationModel>> getNotificationsByType(String type);

  Future<NotificationModel> getNotificationById(String id);

  Future<void> editNotification(NotificationModel notification);                // So when you call this function, you must supply a NotificationModel object. That object contains all the data fields (id, title, body, donorId, timestamp, isRead) which/that the function will use to update the notification in Firestore.

  Future<void> markAllAsRead(String id);

  Future<void> deleteNotification(String id);

  Future<void> sendNotificationToUser(String token, String title, String body);

  Future<void> saveUserFcmToken();

  Future<String> getReceiverName(String receiverId);

  Future<List<NotificationModel>> getAllNotifications();

  Future<String?> getFcmTokenForUser(String receiverId);

  Future<void> markAsRead(String id);
}


// Note: repo = talks with firestore to save and fetch data into it and from it.
// Note: repo = only defines what function exits with hiding implementation of functions. Eg: addUser, deleteUser, etc.

// Note: Abstract class = blueprint (defines what must exist).
// ViewModel talks only to the abstract repo (the blueprint without detailed inner function works). This way it helps to keep MVVM architecture clean.

// Breaking this code: (Future<void> editNotification(NotificationModel notification);) down fully:
// Function name: editNotification → what the function does.
// Return type: Future<void> → it runs asynchronously and doesn’t return a value.
// Parameter: NotificationModel notification → the input the function requires.
