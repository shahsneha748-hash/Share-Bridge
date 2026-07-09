import 'package:sharebridge/model/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sharebridge/model/notification_model.dart';

abstract class NotificationRepo {

  Future<NotificationSettings> requestPermission();


  Future<String?> getFcmToken(String uid);

  Future<bool> sendPushNotification({
    required String deviceToken,
    required NotificationModel notification,
    required String projectId,
    required String serviceAccountPath,
  });

  Stream<List<NotificationModel>> getNotifications(String uid);

  Future<bool> addNotification(NotificationModel notification);

  Future<List<NotificationModel>> getNotificationsByUser(String userId);

  Future<List<NotificationModel>> getNotificationsByType(String type);

  Future<NotificationModel> getNotificationById(String id);

  Future<void> editNotification(NotificationModel notification);

  Future<void> markAllAsRead(String id);

  Future<void> deleteNotification(String id);

  Future<void> sendNotification(NotificationModel model);

  Future<void> saveUserFcmToken();

  Future<String> getReceiverName(String receiverId);

  Future<List<NotificationModel>> getAllNotifications();

  Future<void> markAsRead(String id);

  Future<void> updateType(String id, String typeString);


}

