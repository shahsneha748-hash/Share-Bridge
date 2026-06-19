import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';


class AcceptNotificationButton extends StatefulWidget {
  const AcceptNotificationButton({super.key});

  @override
State<AcceptNotificationButton> createState() => _AcceptNotificationButtonState();
}

class _AcceptNotificationButtonState extends State<AcceptNotificationButton> {
  // @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Notification Button"),
        ),
        body:
        Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final model = NotificationModel(
                    id: "",
                    senderId: FirebaseAuth.instance.currentUser!.uid,
                    receiverId: "receiverUserIdHere",
                    type: "test",
                    title: "Test Notification",
                    body: "This is a popup notification",
                    createdAt: DateTime.now(),
                    isRead: false,
                  );

                  await NotificationService.display(
                    title: model.title,
                    body: model.body,
                    payload: "notification_screen",
                    buildContext: context,
                  );
                },
                child: const Text("Trigger Popup"),
              )



            ]
        )
    );
  }
}
      // child: Text("Accept Request"),


