import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/view/notification_screen.dart';
import 'package:sharebridge/view/pickup_notification_screen.dart';
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
      child: Row(
        children: [
          FloatingActionButton(
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

          SizedBox(width: 20,),

          FloatingActionButton(
            onPressed: () async {
              final vm = context.read<NotificationViewModel>();

              final receiverId = "receiverUserId"; // dynamic in real flow
              final receiverName = await vm.getReceiverName(receiverId);

              final model = NotificationModel(
                id: "",
                senderId: FirebaseAuth.instance.currentUser!.uid,
                receiverId: receiverId,
                type: "request",
                title: "$receiverName has requested for your donation",
                body: "Choose accept or reject",
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
          ),

          SizedBox(width: 20,),
          // This button must be in volunteer page:
          FloatingActionButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PickupNotificationScreen()));
          }, child: Text("Pickup Notification")),

          // CachedNetworkImage(
          //   height: 100,width: 100,
          //   imageUrl: data.imageUrl.toString(),
          //   placeholder: (context, url) =>
          //   const Center(child: CircularProgressIndicator()),
          //   errorWidget: (context, url, error) =>
          //   const Icon(Icons.error),
          // ),
          // Image.asset("assets/images/Mila1.png"),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text("${data.name}"),
          //     Text("${data.description}"),
          //
          //     TextButton(
          //       onPressed: () {
          //         Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) =>
          //                 PickupNotificationScreen(id: data.id.toString()),
          //           ),
          //         );
          //       },
          //       child: Text("Edit"),
          //     ),
          //     TextButton(
          //       onPressed: () async {
          //         await vm.deleteproduct(data.id.toString());
          //       },
          //       child: Text("Delete"),
          //     ),
          //   ],
          // ),
        ],
      ),
    ),),

    ],
        )
    );
  }
}
