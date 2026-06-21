import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/view/notification_screen.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';

class Homescreentest extends StatefulWidget {
  const Homescreentest({super.key});

  @override
  State<Homescreentest> createState() => _HomescreentestState();
}

class _HomescreentestState extends State<Homescreentest> {

  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    // When app is launched from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("Terminated launch: $message");
        // Navigate if needed
      }
    });

    // Get FCM token
    FirebaseMessaging.instance.getToken().then((value) {
      print("📱 FCM Token: $value");
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print("Foreground: ${message.notification!.title}");
        print("Foreground: ${message.notification!.body}");

      }

      // Show local popup
      NotificationService.displayFcm(
        notification: message.notification!,
        buildContext: context,
      );
    });

    // Background (when user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Background tap: $message");
      // Navigate if needed
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home Screen Test"),
          actions: [
            Consumer<NotificationViewModel>(
              builder: (context, vm, child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Badge(
                    // Only show badge if unreadCount > 0
                    isLabelVisible: vm.unreadCount > 0,
                    label: Text(
                      vm.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        body:
        Column(
          children: [
            ElevatedButton(
            onPressed: () async {
    final vm = context.read<NotificationViewModel>();

    final model = NotificationModel(
    id: "",
    senderId: FirebaseAuth.instance.currentUser!.uid,
    receiverId: "receiverUserIdHere",
    type: "alert", // special type
    title: "Urgent Alert",
    body: "Food item expires today", // custom description
    createdAt: DateTime.now(),
    isRead: false,
    );

    await vm.addNotification(model);

    await NotificationService.display(
    title: model.title,
    body: model.body,
    payload: "notification_screen",
    buildContext: context,
    );
    },
      child: const Text("Trigger Alert"),
    ),

    ElevatedButton(
    onPressed: () async {
    final vm = context.read<NotificationViewModel>();

    final receiverId = "receiverUserId"; // dynamic in real flow
    final receiverName = await vm.getReceiverName(receiverId);

    final model = NotificationModel(
    id: "",
    senderId: FirebaseAuth.instance.currentUser!.uid,
    receiverId: receiverId,
    type: "request",
    title: "$receiverName is interested in your donation",
    body: "Please accept or reject this request.",
    createdAt: DateTime.now(),
    isRead: false,
    );

    await vm.addNotification(model);

    await NotificationService.display(
    title: model.title,
    body: model.body,
    payload: "notification_screen",
    buildContext: context,
    );
    },
    child: const Text("Request Notification"),
    )

    ],
        )
    );
  }
}
