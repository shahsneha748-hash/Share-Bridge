import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:sharebridge/model/pickup_notification_model.dart';
import 'package:sharebridge/repo/pickup_notification_repo.dart';
import 'package:sharebridge/service/fcm_service.dart';
import '../model/notification_model.dart';
import 'notification_repo.dart';

class PickupNotificationRepoImpl implements PickupNotificationRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

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
  Future<String?> getFcmToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      print("Failed to get FCM token: $e");
      return null;
    }
  }

  @override
  Future<bool> addPickupNotification(
      PickupNotificationModel notification) async {
    try {
      final ref = firestore.collection("notifications").doc();
      final newNotification = notification;
      await ref.set(newNotification.toMap());
      return true;
    } catch (e) {
      print("Failed to add notification: $e");
      return false;
    }
  }

  @override
  Future<void> deletePickupNotification(String id) {
    return firestore.collection("notifications").doc(id).delete();
  }

  @override
  Future<void> editPickupNotification(PickupNotificationModel notification) {
    return firestore.collection("notifications").doc(notification.id).update(
        notification.toMap());
  }

  @override
  Future<List<PickupNotificationModel>> getAllPickupNotifications() async {
    final snapshot = await firestore.collection("notifications").get();
    return snapshot.docs
        .map((doc) => PickupNotificationModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Stream<List<PickupNotificationModel>> getPickupNotifications(String userId) {
    return firestore
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) => PickupNotificationModel.fromMap(doc.data()))
            .toList());
  }


  @override
  Future<List<PickupNotificationModel>> getPickupNotificationsByType(
      String type) async {
    final snapshot = await firestore
        .collection("notifications")
        .where("type", isEqualTo: type)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => PickupNotificationModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<PickupNotificationModel> getPickupNotificationsByUser(
      String id) async {
    final doc = await firestore.collection("notifications").doc(id).get();
    if (!doc.exists) throw Exception("Notification not found");
    return PickupNotificationModel.fromMap(doc.data()!);
  }

  @override
  Future<bool> sendPushPickupNotification({
    required String deviceToken,
    required PickupNotificationModel notification,
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

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final message = {
        'message': {
          'token': deviceToken,
          'notification': {
            'title': notification.title ?? "No Title",
            'body': notification.description ?? "No Description",
          },
          'data': {
            'id': notification.id,
            'senderId': notification.senderId,
            'receiverId': notification.receiverId,
          },
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

  @override
  Future<String> getReceiverName(String receiverId) async {
    final doc = await firestore.collection("users").doc(receiverId).get();
    if (!doc.exists) throw Exception("Receiver not found");
    return doc.data()?["name"] ?? "Unknown";
  }
}
