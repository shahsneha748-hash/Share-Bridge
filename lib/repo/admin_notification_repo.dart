abstract class AdminNotificationRepo {
  Future<List<Map<String, dynamic>>> fetchNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}