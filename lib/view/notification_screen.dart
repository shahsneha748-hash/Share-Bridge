import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/components/notification_card.dart'; // use the clean card
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/view/request_system_screen.dart';
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        backgroundColor: const Color(0XFF435944),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFFb9c7b4),
                foregroundColor: const Color(0XFF435944),
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
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: ListView.builder(
          itemCount: sections.length,
          itemBuilder: (context, sectionIndex) {
            final section = sections[sectionIndex];
            final items = grouped[section] ?? [];

            if (items.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    section,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Cards for this section
                Column(
                  children: items.map((n) {
                    return InkWell(
                      onTap: () {
                        if (n.type == NotificationType.request) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RequestSystemScreen(),
                            ),
                          );
                        }
                      },
                      child: NotificationCard(
                        notification: n,
                        type: n.type,
                        body: n.body ?? "",
                        createdAt: n.createdAt,
                        profilePicture: n.profilePicture ?? "",
                        onMarkAsRead: () => vm.markAsRead(n.id),
                      ),
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