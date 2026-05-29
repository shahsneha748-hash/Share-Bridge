import 'package:sharebridge/model/notification_model.dart';

abstract class NotificationRepo {
  Future<void> addNotification(NotificationModel notification);     // Add a new notification (e.g., request received, expiry alert) (This is C create (means add) from CRUD needs). Note for abstract class always first see CRUDE needs first.
  Future<void> deleteNotification(String id);        // Delete a notification by ID (This is D delete (means delete) from CRUD needs).
  Future<void> markAsRead(String id);         // Mark a notification as read (This is U update from CRUDE needs (means u can update notification as read or unread) ).
  Future<List<NotificationModel>> getNotificationsByUser(String userId);      // Get all notifications for a specific user (This is R read (means to get notification) from CRUD needs).
  Future<List<NotificationModel>> getNotificationsByType(String type);       // Get notifications by type (e.g., "request", "acceptance", "expiry")  (This is also R read (means to get notification) from CRUD needs)
  Future<NotificationModel> getNotificationById(String id);         // Get a single notification by ID (This is also R read (means to get notification) from CRUD needs)
  Future<void> editNotification(NotificationModel notification);    // Edit/update an existing notification (e.g., change message or status)  (This is U update from CRUDE needs (Update means = modify existing notification data (message, status, type, etc.))).
}
