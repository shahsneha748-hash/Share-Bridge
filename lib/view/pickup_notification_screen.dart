import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';

class PickupNotificationScreen extends StatefulWidget {
  final String receiverUid;

  const PickupNotificationScreen({super.key, required this.receiverUid});

  @override
  State<PickupNotificationScreen> createState() => _PickupNotificationScreenState();
}

class _PickupNotificationScreenState extends State<PickupNotificationScreen> {
  final TitleController = TextEditingController();
  final BodyController = TextEditingController();

  NotificationService notificationService = NotificationService();


  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("Terminated launch: $message");
      }
    });

    FirebaseMessaging.instance.getToken().then((value) {
      print("📱 FCM Token: $value");
    });

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print("Foreground: ${message.notification!.title}");
        print("Foreground: ${message.notification!.body}");
      }

      NotificationService.displayFcm(
        notification: message.notification!,
        buildContext: context,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Background tap: $message");
    });
  }

  Widget buildProfileImage(String? profilePicture) {
    if (profilePicture == null || profilePicture.isEmpty) {
      return const CircleAvatar(radius: 40, child: Icon(Icons.person));
    }
    if (profilePicture.startsWith("http")) {
      return CircleAvatar(radius: 40, backgroundImage: NetworkImage(profilePicture));
    }
    if (profilePicture.startsWith("/")) {
      return CircleAvatar(radius: 40, backgroundImage: FileImage(File(profilePicture)));
    }
    return CircleAvatar(radius: 40, backgroundImage: AssetImage(profilePicture));
  }

  Future<String?> _getProfilePictureFromFirestore(String userId) async {
    final doc = await FirebaseFirestore.instance.collection("users").doc(userId).get();
    if (!doc.exists) return null;
    return doc.data()?["profilePicture"];
  }

  String formatRelativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h";
    } else if (diff.inDays < 30) {
      return "${diff.inDays}d";
    } else {
      return "30d";
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Pickup Notification")),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                FutureBuilder<String?>(
                  future: _getProfilePictureFromFirestore(currentUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(radius: 40, child: CircularProgressIndicator());
                    }
                    return buildProfileImage(snapshot.data);
                  },
                ),

                const SizedBox(width: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: TextFormField(
                    controller: TitleController,
                    decoration: InputDecoration(
                      hintText: "Title",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: TextFormField(
                    controller: BodyController,
                    decoration: InputDecoration(
                      hintText: "Description",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    if (BodyController.text.trim().isEmpty) {
                      Fluttertoast.showToast(msg: "All fields must be filled");
                      return;
                    }

                    final vm = context.read<NotificationViewModel>();
                    final senderInfo = await vm.getUserById(currentUserId);
                    final senderName = senderInfo.fullName;
                    final senderPic = senderInfo.profilePicture;

                    final receiverId = "TGkOS5JmBsXMgGVtA1RaifvNKXl2";
                    final receiverInfo = await vm.getUserById(receiverId);

                    final model = NotificationModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      body: BodyController.text.trim(),
                      senderId: currentUserId,
                      senderName: senderName,
                      profilePicture: senderPic,
                      receiverId: receiverId,
                      receiverName: receiverInfo.fullName,
                      createdAt: DateTime.now(),
                      isRead: false,
                      type: NotificationType.pickup,
                      postId: "",
                    );

                    final success = await vm.sendNotification(model);

                    if (success) {
                      await NotificationService.display(
                        body: model.body,
                        payload: "pickup_notification_screen",
                        buildContext: context,
                        createdAt: model.createdAt,
                      );

                      Navigator.pop(context);

                      Fluttertoast.showToast(msg: "Notification sent successfully");
                    } else {
                      Fluttertoast.showToast(msg: "Failed to send notification");
                    }
                  },
                  child: const Text("Send Notification"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
