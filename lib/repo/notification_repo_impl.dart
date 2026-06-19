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

  /// Request Firebase Messaging permissions
  @override
  Future<NotificationSettings> requestPermission() {
    return messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> saveUserFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "fcmToken": token,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("Token saved for ${user.uid}: $token");
    }
  }



  /// Get FCM token for this device
  @override
  Future<String?> getFcmToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      print("Failed to get FCM token: $e");
      return null;
    }
  }

  /// Send push notification using FCM HTTP v1 API
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
      final serviceAccount =
      ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(serviceAccount, scopes);
      final accessToken = client.credentials.accessToken.data;

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final message = {
        'message': {
          'token': deviceToken,
          'notification': {
            'title': notification.title,
            'body': notification.body,
          },
          'data': notification.data ?? {},
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Failed to send push notification: $e");
      return false;
    }
  }

  /// Stream notifications for a user (real-time updates)
  @override
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return firestore
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList());
  }

  /// Add a new notification
  @override
  Future<bool> addNotification(NotificationModel notification) async {
    try {
      final ref = firestore.collection("notifications").doc();
      final newNotification = notification.copyWith(
        id: ref.id,
        createdAt: DateTime.now(),
        isRead: false,
      );
      await ref.set(newNotification.toMap());
      print("Notification added with ID: ${ref.id}");
      return true;
    } catch (e) {
      print("Failed to add notification: $e");
      return false;
    }
  }

  /// Get notifications by userId
  @override
  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    final snapshot = await firestore
        .collection("notifications")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get notifications by type
  @override
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    final snapshot = await firestore
        .collection("notifications")
        .where("type", isEqualTo: type)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get a single notification by ID
  @override
  Future<NotificationModel> getNotificationById(String id) async {
    final doc = await firestore.collection("notifications").doc(id).get();
    if (!doc.exists) throw Exception("Notification not found");
    return NotificationModel.fromMap(doc.data()!);
  }

  /// Edit/update a notification
  @override
  Future<void> editNotification(NotificationModel notification) async {
    await firestore
        .collection("notifications")
        .doc(notification.id)
        .update(notification.toMap());
    print("Notification ${notification.id} updated");
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await firestore.collection("notifications").doc(id).delete();
      print("Notification $id deleted");
    } catch (e) {
      print("Failed to delete notification: $e");
      rethrow;
    }
  }


  @override
  Future<void> markAsRead(String id) async {
    try {
      Future<void> markAsRead(String id) async {
        await FirebaseFirestore.instance
            .collection("notifications")
            .doc(id)
            .update({"isRead": true});
        // Firestore listener will update automatically
      }
      print("Notification $id marked as read");
    } catch (e) {
      print("Failed to mark notification as read: $e");
      rethrow;
    }
  }

  @override
  Future<void> sendNotificationToUser(String token, String title, String body) async {
    await FCMService.sendPushMessage(
      token,
      {"title": title, "body": body},   // data payload
      {"title": title, "body": body},   // notification payload
    );
  }

  @override
  Future<String> getReceiverName(String receiverId) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(receiverId)
        .get();

    return doc.data()?['name'] ?? "Unknown User";
  }
}




