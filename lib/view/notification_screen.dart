import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/components/notification_card.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get ViewModel from Provider
    final vm = context.watch<NotificationViewModel>();
    final grouped = vm.groupNotifications();
    final sections = ["Urgent", "Today", "PastDates"];

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications"),
          backgroundColor: Color(0XFF435944),
          actions: [
          ElevatedButton(
          onPressed: () {
        // Call your ViewModel method to mark all as read
        final vm = context.read<NotificationViewModel>();
    vm.markAllAsRead();
  },
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white, // button color
    foregroundColor: const Color(0XFF435944), // text color
    ),
    child: const Text("Mark as Read"),
    ),
    ],
      ),
      body: ListView.builder(
        itemCount: sections.length,
        itemBuilder: (context, sectionIndex) {
          final section = sections[sectionIndex];
          final items = grouped[section]!;

          if (items.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  section == "PastDates" ? "Previous Days" : section,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Cards for this section
              Column(
                children: items.map((n) {
                  NotificationType type;
                  switch (n.type) {
                    case "request":
                      type = NotificationType.request;
                      break;
                    case "pickup":
                      type = NotificationType.pickup;
                      break;
                    case "normal alert":
                      type = NotificationType.normal_alert;
                      break;
                    case "alert":
                      type = section == "Urgent"
                          ? NotificationType.alert
                          : NotificationType.normal_alert;
                      break;
                    default:
                      type = NotificationType.request;
                  }

                  return NotificationCard(
                    type: type,
                    title: n.title ?? "Notification",   // required
                    body: n.body,         // required
                    profilePicture: n.profilePicture,   // optional
                    numberField: n.pickupNumber,
                    onAccept: () =>
                        vm.sendNotification("accepted", n.receiverId),
                    onReject: () =>
                        vm.sendNotification("rejected", n.receiverId),
                    onMarkAsRead: () => vm.markAsRead(n.id),
                  );
                }).toList(),
              ),
            ],
          );
        },
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