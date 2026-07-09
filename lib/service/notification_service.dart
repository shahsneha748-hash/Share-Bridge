import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view/request_system_screen.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  debugPrint("Background notification tapped: ${response.payload}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static BuildContext? context;

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static Future<void> displayFcm({
    required RemoteNotification notification,
    BuildContext? buildContext,
    String? payload,
  }) async {
    try {
      if (buildContext != null) context = buildContext;

      BigPictureStyleInformation? styleinformationDesign;
      if (notification.android?.imageUrl != null) {
        final bigpicture = await _downloadAndSaveFile(
            notification.android!.imageUrl!, 'bigPicture');
        final smallpicture = await _downloadAndSaveFile(
            notification.android!.imageUrl!, 'smallIcon');
        styleinformationDesign = BigPictureStyleInformation(
          FilePathAndroidBitmap(bigpicture),
          largeIcon: FilePathAndroidBitmap(smallpicture),
        );
      }

      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "myapp",
          "myapp channel",
          channelDescription: "myapp channel description",
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: styleinformationDesign,
          ongoing: true,
          autoCancel: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        id: id,
        title: notification.title ?? "No Title",
        body: notification.body ?? "No Body",
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print("Notification error: $e");
    }
  }

  static Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload == "request_system_screen") {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => RequestSystemScreen()),
          );
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

  }

  static Future<void> requestPermissionOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool("notificationsAsked") ?? false;

    if (asked) return;

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      AppSettings.openAppSettings();
    }

    await prefs.setBool("notificationsAsked", true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set({
          "fcmToken": token,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set({
          "fcmToken": newToken,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  static Future<String> getImageFilePathFromAssets(
      String asset, String filename) async {
    final byteData = await rootBundle.load(asset);
    final tempDirectory = await getTemporaryDirectory();
    final file = File('${tempDirectory.path}/$filename');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file.path;
  }

  static Future<void> display({
    required String body,
    String? payload,
    BuildContext? buildContext,
    String? image,
    String? logo,
    required DateTime createdAt,
  }) async {
    if (buildContext != null) context = buildContext;

    BigPictureStyleInformation? styleinformationDesign;
    if (image != null && logo != null) {
      try {
        var imageLoader = await getImageFilePathFromAssets(image, 'bigpicture');
        var notificationImage = FilePathAndroidBitmap(imageLoader);
        var imageLoaderLogo =
        await getImageFilePathFromAssets(logo, 'smallpicture');
        var notificationLogo = FilePathAndroidBitmap(imageLoaderLogo);
        styleinformationDesign = BigPictureStyleInformation(
          notificationImage,
          largeIcon: notificationLogo,
        );
      } catch (e) {
        print("Notification Error: $e");
      }
    }

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        "myapp",
        "myapp channel",
        channelDescription: "myapp channel description",
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: styleinformationDesign,
        ongoing: true,
        autoCancel: true,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: "Notification",
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }


}








