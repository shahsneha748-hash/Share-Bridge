// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:sharebridge/model/notification_model.dart';
// import 'package:sharebridge/repo/notification_repo.dart';
// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/services.dart';
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:http/http.dart' as http;
//
// // CLASS DECLARATION
// class NotificationRepoImpl implements NotificationRepo {                   // implements NotificationRepo → this class must provide all methods defined in the abstract repo.
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;          // instance to interact with Firestore.
//   final FirebaseMessaging messaging = FirebaseMessaging.instance;          // instance to interact with Firebase messaging.
// // Note: instance variables "firestore and messaging"=> created once when the class is instantiated, and then reused by all methods in that class => this avoids repeating FirebaseFirestore.instance or FirebaseMessaging.instance in every function.
//
//   // PERMISSIONS
//   @override
//   Future<NotificationSettings> requestPermission() {
//     return messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
//
//   // TOKEN
//   @override
//   Future<String?> getFcmToken() async {     // Future<String?> → the function will eventually give a string (token).   // async → allows use of await inside.    // return await messaging.getToken() → waits for Firebase to generate the token, then returns it.
//     return await messaging.getToken();      // messaging.getToken() → retrieves the device’s FCM token.
//   }
// // Note: This function "getFcmToken" will asynchronously fetch the FCM token and return it once ready.// Note this code means:
//
//   // SENDING PUSH NOTIFICATIONS
//   @override
//   Future<bool> sendPushNotification({
//     required String deviceToken,
//     required NotificationModel notification,
//     required String projectId,
//     required String serviceAccountPath,
//   }) async {
//     if (deviceToken.isEmpty) return false;
//
//     final serviceAccountJson = await rootBundle.loadString(serviceAccountPath);
//     final serviceAccount = ServiceAccountCredentials.fromJson(serviceAccountJson);
//     final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
//     final client = await clientViaServiceAccount(serviceAccount, scopes);
//     final accessToken = client.credentials.accessToken.data;
//
//     final url = Uri.parse(
//       'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
//     );
//
//     final message = {
//       'message': {
//         'token': deviceToken,
//         'notification': {
//           'title': notification.title,
//           'body': notification.body,
//         },
//         'data': notification.data ?? {},
//       },
//     };
//
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: jsonEncode(message),
//     );
//
//     return response.statusCode == 200;
//   }
//
//   // 🔹 Firestore CRUD
//   @override
//   Future<void> addNotification(NotificationModel notification) async {
//     final ref = firestore.collection("notifications").doc();           // Example: firestore.collection("notifications") → points to your notifications collection.
//     notification.id = ref.id;
//     await ref.set(notification.toMap());
//   }
//
//   @override
//   Future<void> markAsRead(String id) {
//     return firestore.collection("notifications").doc(id).update({'isRead': true});
//   }
//
//   @override
//   Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
//     final snapshot = await firestore
//         .collection("notifications")
//         .where('userId', isEqualTo: userId)
//         .orderBy('timestamp', descending: true)
//         .get();
//
//     return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();
//   }
//
//   @override
//   Future<List<NotificationModel>> getNotificationsByType(String type) async {
//     final snapshot = await firestore
//         .collection("notifications")
//         .where('type', isEqualTo: type)
//         .orderBy('timestamp', descending: true)
//         .get();
//
//     return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();
//   }
//
//   @override
//   Future<NotificationModel> getNotificationById(String id) async {
//     final doc = await firestore.collection("notifications").doc(id).get();
//     if (!doc.exists) throw Exception("Notification not found");
//     return NotificationModel.fromMap(doc.data()!);
//   }
//
//   @override
//   Future<void> editNotification(NotificationModel notification) {
//     return firestore.collection("notifications").doc(notification.id).update(notification.toMap());
//   }
// }
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/notification_model.dart';
import 'notification_repo.dart';

class NotificationRepoImpl implements NotificationRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  Future<NotificationSettings> requestPermission() {
    return messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  @override
  Future<String?> getFcmToken() async {
    return await messaging.getToken();
  }

  @override
  Future<bool> sendPushNotification({
    required String deviceToken,
    required NotificationModel notification,
    required String projectId,
    required String serviceAccountPath,
  }) async {
    if (deviceToken.isEmpty) return false;

    final serviceAccountJson = await rootBundle.loadString(serviceAccountPath);
    final serviceAccount = ServiceAccountCredentials.fromJson(serviceAccountJson);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(serviceAccount, scopes);
    final accessToken = client.credentials.accessToken.data;

    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

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
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    final ref = firestore.collection("notifications").doc();
    notification.id = ref.id;
    await ref.set(notification.toMap());
  }

  @override
  Future<List<NotificationModel>> getNotificationsByUser(String userId) async {
    final snapshot = await firestore
        .collection("notifications")
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();
  }

  @override
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    final snapshot = await firestore
        .collection("notifications")
        .where('type', isEqualTo: type)
        .orderBy('timestamp', descending: true)
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
  Future<void> editNotification(NotificationModel notification) {
    return firestore.collection("notifications").doc(notification.id).update(notification.toMap());
  }
}
