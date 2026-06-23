import 'dart:io';
import 'package:flutter/material.dart';

enum NotificationType { request, pickup, alert, normal_alert }

class NotificationCard extends StatelessWidget {
  final NotificationType type;
  final String? profilePicture;
  final String title;          // comes from constructor
  final String body;
  final String? numberField;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    required this.type,
    this.profilePicture,
    required this.title,
    required this.body,
    this.numberField,
    this.onAccept,
    this.onReject,
    this.onMarkAsRead,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    String cardTitle; // renamed to avoid shadowing
    ShapeBorder? cardShape;
    double? cardElevation;

    switch (type) {
      case NotificationType.request:
        bgColor = Colors.white;
        cardTitle = "Donation Request";
        cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
        cardElevation = 2;
        break;

      case NotificationType.pickup:
        bgColor = Colors.white;
        cardTitle = "Pickup Scheduled";
        cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
        cardElevation = 2;
        break;

      case NotificationType.alert:
        bgColor = const Color(0xFFeed2d2);
        cardTitle = "Alert!";
        cardShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFe8a4a4)),
        );
        cardElevation = 6;
        break;

      case NotificationType.normal_alert:
        bgColor = Colors.white;
        cardTitle = "Normal Alert!";
        cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
        cardElevation = 2;
        break;

      default:
        bgColor = Colors.white;
        cardTitle = "Notification";
        cardShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
        cardElevation = 2;
    }

    Widget buildProfileImage(String? profilePicture) {
      if (profilePicture == null || profilePicture.isEmpty) {
        return const CircleAvatar(radius: 25, child: Icon(Icons.person));
      }
      if (profilePicture.startsWith("http")) {
        return CircleAvatar(radius: 25, backgroundImage: NetworkImage(profilePicture));
      } else if (profilePicture.startsWith("/")) {
        return CircleAvatar(radius: 25, backgroundImage: FileImage(File(profilePicture)));
      } else {
        return CircleAvatar(radius: 25, backgroundImage: AssetImage(profilePicture));
      }
    }

    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProfileImage(profilePicture),
            const SizedBox(height: 8),
            Text(cardTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(body),
            if (numberField != null) Text("Pickup Number: $numberField"),
            Row(
              children: [
                if (onAccept != null)
                  ElevatedButton(onPressed: onAccept, child: const Text("Accept")),
                if (onReject != null)
                  ElevatedButton(onPressed: onReject, child: const Text("Reject")),
                if (onMarkAsRead != null)
                  TextButton(onPressed: onMarkAsRead, child: const Text("Mark as read")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



