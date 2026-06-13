import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;

class NotificationService {
final _firebaseMessaging = FirebaseMessaging.instance;

  initFCM()async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message: ${message.notification!.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message opened app: ${message.notification!.title}');
  });
  }
  }
//
//   void requestNotificationPermission() async {
//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       criticalAlert: false,
//       sound: true,
//     );
//
//     if(settings.authorizationStatus == AuthorizationStatus.authorized){
//       print('Permission granted by user');
//     } else if (settings.authorizationStatus == AuthorizationStatus.provisional){
//       print('Permission granted provisionally');
//     } else {
//       print('Permission denied by user');
//     }
//   }
//
//   Future<String> getFcmToken() async {                   // Firebase uses FcmToken to uniquely identify a device and send notification to it. FCM token extremly important in push notification without it they cannot target a specific device
//     String? token = await messaging.getToken();
//     print('Token: $token');
//     return token!;
//   }
//
//   Future<AccessCredentials> _getAccessToken() async {
//     final serviceAccountPath = dotenv.env['PATH_TO_SECRET'];              // to get AccessToken here we are taking the path of the service account path from environment variable and loading the screen from the json file
//
//     String serviceAccountJson = await rootBundle.loadString(              // then we are loading the string from the json file
//       serviceAccountPath!,
//     );
//
//     // log("json: $serviceAccountJson");
//     final serviceAccount = ServiceAccountCredentials.fromJson(            // then we are using this "ServiceAccountCredentials" from json file to get the credentials we need from the key.json file from the secrets folder
//       serviceAccountJson,
//     );
//
//     final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
//
//     final client = await clientViaServiceAccount(serviceAccount, scopes);
//     return client.credentials;
//   }
//
//   Future<bool> sendPushNotification({
//     required String deviceToken,
//     required String title,
//     required String body,
//     Map<String, dynamic>? data,
//   }) async {
//     if (deviceToken.isEmpty) return false;
//
//     final credentials = await _getAccessToken();
//     final accessToken = credentials.accessToken.data;
//     final projectId = dotenv.env['PROJECT_ID'];
//
//     await Future.delayed(Duration(seconds: 2));
//
//     final url = Uri.parse(
//       'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
//     );
//
//     final message = {
//       'message': {
//         'token': deviceToken,
//         'notification': {'title': title, 'body': body},
//         'data': data ?? {},
//       },
//     };
//
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: jsonEncode(message),                        // we json encode the message and send it
//     );
//
//     if (response.statusCode == 200) {                   // if response code is 200 then we return true and prints message "succesful" else returns false and prints message "failed"
//       print('Notification sent successfully.');
//       return true;
//     } else {
//       print('Failed to send notification: ${response.body}');
//       return false;
//     }
//   }
//
// }
