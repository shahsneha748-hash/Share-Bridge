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

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // This will run when a notification is tapped in background
  debugPrint("Background notification tapped: ${response.payload}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static BuildContext? context;

  /// Download and save file (for big picture notifications)
  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  /// Display FCM notification
  static Future<void> displayFcm({
    required RemoteNotification notification,
    BuildContext? buildContext,
    String? payload,
  }) async {
    try {
      if (buildContext != null) {
        context = buildContext;
      }

      var styleinformationDesign;
      if (notification.android?.imageUrl != null) {
        final bigpicture = await _downloadAndSaveFile(
            notification.android!.imageUrl!, 'bigPicture');
        final smallpicture = await _downloadAndSaveFile(
            notification.android!.imageUrl!, 'smallIcon');
        styleinformationDesign = BigPictureStyleInformation(
          FilePathAndroidBitmap(smallpicture),
          largeIcon: FilePathAndroidBitmap(bigpicture),
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
    } on Exception catch (e) {
      print("Notification error: $e");
    }
  }

  /// Initialize notifications + request permissions
  static Future<void> initialize() async {
    // Android 13+ permission
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // iOS permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permission granted by user');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Provisional permission granted');
    } else {
      AppSettings.openAppSettings();
      print('User denied the permission');
    }

    // Initialize plugin
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      ),
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification tapped: ${response.payload}");
        if (response.payload != null && context != null) {
          Navigator.of(context!).pushNamed(response.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground, // 👈 use top-level function
    );

    // Save initial token
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
        print("✅ Initial token saved for ${user.uid}: $token");
      }
    }

    // Listen for token refresh
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
        print("🔄 Token refreshed for ${user.uid}: $newToken");
      }
    });
  }



  /// Load image from assets
  static Future<String> getImageFilePathFromAssets(
      String asset, String filename) async {
    final byteData = await rootBundle.load(asset);
    final tempDirectory = await getTemporaryDirectory();
    final file = File('${tempDirectory.path}/$filename');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file.path;
  }

  /// Display custom notification (with asset images)
  /// Display custom notification (with asset images)
  static Future<void> display({
    required String title,
    required String body,
    String? payload,
    BuildContext? buildContext,
    String? image,
    String? logo,
  }) async {
    if (buildContext != null) {
      context = buildContext;
    }

    var styleinformationDesign;
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
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

}
