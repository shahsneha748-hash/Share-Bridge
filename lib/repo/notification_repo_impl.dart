import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:sharebridge/service/fcm_service.dart';
import '../model/notification_model.dart';
import 'notification_repo.dart';

class NotificationRepoImpl implements NotificationRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  Future<NotificationSettings> requestPermission() {
    return messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> saveUserFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await messaging.getToken();
    if (token != null) {
      await firestore.collection("users").doc(user.uid).set({
        "fcmToken": token,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Future<String?> getFcmToken(String uid) async {
    final doc = await firestore.collection("users").doc(uid).get();
    return doc.data()?["fcmToken"];
  }

  @override
  Future<bool> sendPushNotification({
    required String deviceToken,
    required NotificationModel notification,
    required String projectId,
    required String serviceAccountPath,
  }) async {
    if (deviceToken.isEmpty) return false;

    try {
      final serviceAccountJson = await rootBundle.loadString(serviceAccountPath);
      final serviceAccount = ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(serviceAccount, scopes);
      final accessToken = client.credentials.accessToken.data;

      final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');
      final message = {
        'message': {
          'token': deviceToken,
          'notification': {'body': notification.body},
          'data': notification.data ?? {},
        },
      };

      final response = await http.post(url,
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
          body: jsonEncode(message));

      return response.statusCode == 200;
    } catch (e) {
      print("Failed to send push notification: $e");
      return false;
    }
  }

  @override
  Stream<List<NotificationModel>> getNotifications(String uid) {
    return firestore
        .collection("notifications")
        .where("receiverId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList());
  }

  @override
  Future<bool> addNotification(NotificationModel model) async {
    try {
      await firestore.collection("notifications").doc(model.id).set({
        "id": model.id,
        "receiverId": model.receiverId,
        "senderId": model.senderId,
        "senderName": model.senderName,
        "type": model.type.toString().split('.').last,
        "body": model.body,
        "createdAt": model.createdAt,
        "isRead": model.isRead,
        "profilePicture": model.profilePicture,
      });
      return true;
    } catch (e) {
      return false;
    }
  }


  @override
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    final snapshot = await firestore
        .collection("notifications")
        .where("type", isEqualTo: type)
        .orderBy("createdAt", descending: true)
        .get();
    return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    final doc = await firestore.collection("notifications").doc(id).get();
    if (!doc.exists) throw Exception("Notification not found");
    return NotificationModel.fromMap(doc.data()!);
  }

  @override
  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    final snapshot = await firestore
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .get();
    return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();
  }


  @override
  Future<void> editNotification(NotificationModel notification) async {
    await firestore.collection("notifications").doc(notification.id).update(notification.toMap());
  }

  @override
  Future<void> deleteNotification(String id) async {
    await firestore.collection("notifications").doc(id).delete();
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final query = await firestore
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .where("isRead", isEqualTo: false)
        .get();

    final batch = firestore.batch();
    for (var doc in query.docs) {
      batch.update(doc.reference, {"isRead": true});
    }
    await batch.commit();
  }

  @override
  Future<bool> sendNotification(NotificationModel model) async {
    try {
      await firestore.collection("notifications").doc(model.id).set(model.toMap());

      final token = await getFcmTokenForUser(model.receiverId);
      if (token == null) return false;

      await FCMService.sendPushMessage(token, {"body": model.body}, {"body": model.body});
      return true;
    } catch (e) {
      print("Error sending notification: $e");
      return false;
    }
  }

  @override
  Future<String> getReceiverName(String receiverId) async {
    final doc = await firestore.collection("users").doc(receiverId).get();
    return doc.data()?['name'] ?? "Unknown User";
  }

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    final snapshot = await firestore.collection("notifications").get();
    return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();
  }

  @override
  Future<String?> getFcmTokenForUser(String receiverId) async {
    try {
      final doc = await firestore.collection("users").doc(receiverId).get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return data["fcmToken"] as String?;
    } catch (e) {
      print("Error fetching FCM token: $e");
      return null;
    }
  }


  @override
  Future<void> markAsRead(String id) async {
    await firestore.collection("notifications").doc(id).update({"isRead": true});
  }

  @override
  Future<void> updateType(String id, String typeString) async {
    await firestore.collection('notifications').doc(id).update({'type': typeString});
  }
}