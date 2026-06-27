import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/components/notification_card.dart' hide NotificationType;
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';
import '../model/notification_model.dart'; // make sure this imports your enum

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();
    final grouped = vm.groupNotifications();
    final sections = ["Urgent", "Today", "Yesterday"];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Color(0XFFf2ead3),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        backgroundColor: Color(0XFF435944),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0XFFb9c7b4),    //Color(0XFFf2ead3),
                // fixedSize: const Size(120, 35),
                foregroundColor: Color(0XFF435944),         //Color(0XFF435944),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                context.read<NotificationViewModel>().markAllAsRead();
              },
              child: const Text(
                "Mark as Read",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15, right: 10, left: 10),
        child: ListView.builder(
          itemCount: sections.length,
          itemBuilder: (context, sectionIndex) {
            final section = sections[sectionIndex];
            final items = grouped[section]?? [];

            if (items.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    section == "PastDates" ? "Yesterday" : section,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Cards for this section
                Column(
                  children: items.map((n) {
                    return NotificationCard(
                      notification: n,
                      type: n.type, // enum directly
                      title: n.title ?? "Notification",
                      body: n.body ?? "",
                      createdAt: n.createdAt,
                      profilePicture: n.profilePicture ?? "",
                      numberField: n.pickupNumber ?? "",

                      // Only show Accept/Reject if it's a request
                      onAccept: n.type == NotificationType.request
                          ? () async {
                        vm.updateNotificationType(n.id, NotificationType.request);

                        final acceptModel = NotificationModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          senderId: FirebaseAuth.instance.currentUser!.uid,
                          receiverId: n.senderId, // send back to requester
                          type: NotificationType.accepted,
                          title: "Request Accepted",
                          body: "Donor has accepted your donation request.",
                          createdAt: DateTime.now(),
                          isRead: false,
                          profilePicture: n.profilePicture ?? "",
                        );

                        await vm.addNotification(acceptModel); // adds new card
                        NotificationService.display(
                          title: acceptModel.title,
                          body: acceptModel.body,
                          payload: "notification_screen",
                          buildContext: context,
                          createdAt: acceptModel.createdAt,
                        );
                      }
                          : null,

                      onReject: n.type == NotificationType.request
                          ? () async {
                        vm.updateNotificationType(n.id, NotificationType.request);

                        final rejectModel = NotificationModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          senderId: FirebaseAuth.instance.currentUser!.uid,
                          receiverId: n.senderId, // send back to requester
                          type: NotificationType.rejected,
                          title: "Request Rejected",
                          body: "Donor has rejected your donation request.",
                          createdAt: DateTime.now(),
                          isRead: false,
                          profilePicture: n.profilePicture ?? "",
                        );

                        await vm.addNotification(rejectModel); // adds new card
                        NotificationService.display(
                          title: rejectModel.title,
                          body: rejectModel.body,
                          payload: "notification_screen",
                          buildContext: context,
                         createdAt: rejectModel.createdAt,
                        );
                      }
                          : null,


                      onMarkAsRead: () => vm.markAsRead(n.id),


                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}





//
// Note: ⚡ Flow Recap
// Model → defines notification data. (Eg: Model = raw data only (like a database row).)
// Repo → fetches/saves notifications from Firestore. (Eg: repo = only defines what function exits with hiding implementation of functions. Eg: addUser, deleteUser, etc. so that MVVM architecture is clean)
// ViewModel → manages state, exposes clean methods.
// View → displays notifications, calls ViewModel methods.   (Eg: Notification Screen => Pure UI, listens to ViewModel via Provider.)