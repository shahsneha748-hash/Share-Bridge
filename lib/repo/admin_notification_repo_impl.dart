import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_notification_repo.dart';

class AdminNotificationRepoImpl implements AdminNotificationRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final snapshot = await _firestore
        .collection('admin_notifications')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      ...doc.data(),
      'id': doc.id,
    }).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('admin_notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead() async {
    final snapshot = await _firestore
        .collection('admin_notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }
}