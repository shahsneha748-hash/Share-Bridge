import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';

Widget _notificationCard(NotificationModel n, NotificationViewModel vm) {
  return Card(
    child: ListTile(
      title: Text(n.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(n.body),
          if (n.type == "request") Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final responseModel = NotificationModel(
                    id: "",
                    senderId: FirebaseAuth.instance.currentUser!.uid,
                    receiverId: n.receiverId,
                    type: "response",
                    title: "Donor accepted your request",
                    body: "Your donation request has been accepted.",
                    createdAt: DateTime.now(),
                    isRead: false,
                  );
                  await vm.addNotification(responseModel);
                },
                child: const Text("Accept"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final responseModel = NotificationModel(
                    id: "",
                    senderId: FirebaseAuth.instance.currentUser!.uid,
                    receiverId: n.receiverId,
                    type: "response",
                    title: "Donor rejected your request",
                    body: "Your donation request has been rejected.",
                    createdAt: DateTime.now(),
                    isRead: false,
                  );
                  await vm.addNotification(responseModel);
                },
                child: const Text("Reject"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
