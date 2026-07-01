import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/view/food_alert_screen.dart';
import 'package:sharebridge/view/notification_screen.dart';
import 'package:sharebridge/view/pickup_notification_screen.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';

class Homescreentest extends StatefulWidget {
  final String uid;



  const Homescreentest({super.key, required this.uid,});

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

  String formatRelativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m"; // minutes
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h"; // hours
    } else if (diff.inDays < 30) {
      return "${diff.inDays}d"; // days
    } else {
      return "30d"; // cap at 30 days
    }
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
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.circle_notifications_sharp,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                    ),
                    // 🔑 Show badge only if unreadCount > 0
                    if (vm.unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            vm.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
    ],
    ),


  body:
        Column(
          children: [
        Card(
        child: Padding(
        padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [

          // This button should be in post page
          ElevatedButton(
            onPressed: () async {
              final vm = context.read<NotificationViewModel>();
              final currentUid = widget.uid;

              final senderInfo = await vm.getUserById(currentUid);

              final model = NotificationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                senderId: currentUid,
                senderName: senderInfo.fullName,
                profilePicture: senderInfo.profilePicture,
                receiverId: 'BmbWYHtwszNrTbRiVgRovbKeEZk2',
                type: NotificationType.alert,
                body: "${senderInfo.fullName} says: Food item expires today",
                createdAt: DateTime.now(),
                isRead: false,
              );

              final success = await vm.addNotification(model);

              if (success) {
                await NotificationService.display(
                  body: model.body,
                  payload: "notification_screen",
                  buildContext: context,
                  createdAt: model.createdAt,
                );
                Fluttertoast.showToast(msg: "Notification sent successfully");
              } else {
                Fluttertoast.showToast(msg: "Failed to send notification");
              }
            },
            child: const Text("Trigger Alert"),
          ),


// Request Item (sender = requester, receiver = post owner)
          ElevatedButton(
            onPressed: () async {
              final vm = context.read<NotificationViewModel>();
              final currentUid = widget.uid;

              final senderInfo = await vm.getUserById(currentUid);

              // Replace with the UID of the post owner (the donor)
              final receiverId = "BmbWYHtwszNrTbRiVgRovbKeEZk2";

              final model = NotificationModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                senderId: currentUid,                 // requester
                senderName: senderInfo.fullName,
                profilePicture: senderInfo.profilePicture,
                receiverId: receiverId,               // donor
                type: NotificationType.request,
                body: "${senderInfo.fullName} has requested for your donation",
                createdAt: DateTime.now(),
                isRead: false,
              );

              final success = await vm.addNotification(model);

              if (success) {
                await NotificationService.display(
                  body: model.body,
                  createdAt: model.createdAt,
                  payload: "request_system_screen",
                  buildContext: context,
                );
                Fluttertoast.showToast(msg: "Notification sent successfully");
              } else {
                Fluttertoast.showToast(msg: "Failed to send notification");
              }
            },
            child: const Text("Request this item"),
          ),


          // This button is food expiry alert button in dashboard page
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FoodAlertScreen(),
                ),
              );
            },
            child: const Text("Normal Food Alert Notification"),
          ),


          SizedBox(width: 20,),

          // This button must be in volunteer page:
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PickupNotificationScreen(receiverUid: widget.uid),         // final make this inside round brackets --> (receiverUid: volunteerUid)
                ),
              );
            },
            child: const Text("Pickup Notification"),
          ),
          SizedBox(width: 20,),

          // ElevatedButton(onPressed: (){
          //   Navigator.push(context, MaterialPageRoute(builder: (context) => ItemDetailDemoScreen(item: {}, uid: '',),));
          // }, child: Text("Item Detail")),

        ],
      ),
    ),),

    ],
        )
    );
  }
}
