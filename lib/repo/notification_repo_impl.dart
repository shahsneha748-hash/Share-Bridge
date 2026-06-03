import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/repo/notification_repo.dart';

class NotificationRepoImpl implements NotificationRepo {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  @override
  Future<void> addNotification(NotificationModel notification) {
    return firestore
        .collection("notifications")
        .doc(notification.id)
        .set(notification.toMap());
  }

  @override
  Future<void> deleteNotification(String id) {
    return firestore
        .collection("notifications")
        .doc(id)
        .delete();
  }

  @override
  Future<void> editNotification(NotificationModel notification) {
    return firestore
        .collection("notifications")
        .doc(notification.id)
        .update(notification.toMap());
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    final doc = await firestore
        .collection("notifications")
        .doc(id)
        .get();

    if (!doc.exists) {
      throw Exception("Notification not found");
    }
    return NotificationModel.fromMap(doc.data()!);
  }


  @override
  Future<List<NotificationModel>> getNotificationsByType(String type) async{
    final notification = await firestore
        .collection("notifications")
        .where('type', isEqualTo: type)
        .orderBy('timestamp', descending: true)
        .get();

    return notification.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();
  }

  //  Returns NotificationModel list with timestamps.
  @override
  Future<List<NotificationModel>> getNotificationsByUser(String userId) async{
    final notification = await firestore
        .collection("notifications")
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return notification.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();

  }

  @override
  Future<void> markAsRead(String id) {
    return firestore
        .collection("notifications")
        .doc(id)
        .update({'isRead': true});
  }

}