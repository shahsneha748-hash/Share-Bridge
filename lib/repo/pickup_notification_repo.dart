
import 'package:sharebridge/model/pickup_notification_model.dart';

abstract class PickupNotificationRepo {

  // Get FCM token
  Future<String?> getFcmToken();

  // Send push notification
  Future<bool> sendPushPickupNotification({
    required String deviceToken,
    required PickupNotificationModel notification,
    required String projectId,
    required String serviceAccountPath,
  });

  Stream<List<PickupNotificationModel>> getPickupNotifications(String userId);

  // CRUD operations with Firestore
  Future<bool> addPickupNotification(PickupNotificationModel notification);

  Future<PickupNotificationModel> getPickupNotificationsByUser(String Id);

  Future<List<PickupNotificationModel>> getPickupNotificationsByType(String type);

  Future<void> editPickupNotification(PickupNotificationModel notification);

  Future<void> deletePickupNotification(String id);

  Future<void> saveUserFcmToken();

  Future<String> getReceiverName(String receiverId);

  Future<List<PickupNotificationModel>?> getAllPickupNotifications();

}
