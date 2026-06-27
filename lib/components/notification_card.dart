import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as context show read;
import 'package:sharebridge/model/notification_model.dart';

import '../viewmodel/notification_view_model.dart';


class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String? profilePicture;
  final String? numberField;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.profilePicture,
    this.numberField,
    this.onAccept,
    this.onReject,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    String cardTitle;
    ShapeBorder? cardShape;
    double? cardElevation;

    switch (type) {
      case NotificationType.request:
        bgColor = Colors.white;
        cardTitle = "Donation Request";
        cardShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        );
        cardElevation = 5;
        break;

      case NotificationType.pickup:
        bgColor = Colors.white;
        cardTitle = "Pickup Scheduled";
        cardShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
    );
        cardElevation = 2;
        break;

      case NotificationType.alert:
        bgColor = const Color(0xFFeed2d2);
        cardTitle = "⚠  Alert!";
        cardShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFe8a4a4)),
        );
        cardElevation = 6;
        break;

      case NotificationType.normal_alert:
        bgColor = Colors.white;
        cardTitle = "Food Expiry Alert!";
        cardShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        );
        cardElevation = 2;
        break;

      case NotificationType.accepted:
        bgColor = Colors.white;
        cardTitle = "Donation Accepted";
        cardShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        );
        cardElevation = 2;
        break;

      case NotificationType.rejected:
        bgColor = Colors.white;
        cardTitle = "Donation Rejected";
        cardShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        );
        cardElevation = 2;
        break;


      default:
        bgColor = Colors.white;
        cardTitle = "Notification";
        cardShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        );
        cardElevation = 2;
    }

    Widget buildProfileImage(String? profilePicture) {
      // Fallback if nothing is provided
      if (profilePicture == null || profilePicture.isEmpty) {
        return const CircleAvatar(radius: 40, child: Icon(Icons.person));
      }

      // Network image (http/https)
      if (profilePicture.startsWith("http")) {
        return CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(profilePicture),
        );
      }

      // Local file path (e.g. /storage/emulated/0/Pictures/...)
      if (profilePicture.startsWith("/")) {
        return CircleAvatar(
          radius: 40,
          backgroundImage: FileImage(File(profilePicture)),
        );
      }

      // Asset image (bundled with app)
      return CircleAvatar(
        radius: 40,
        backgroundImage: AssetImage(profilePicture),
      );
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


    return Card(
      color: bgColor,
      shape: cardShape,
      elevation: cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProfileImage(profilePicture),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cardTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(body),

                  // 🕒 Relative time after description
                  Text(
                    formatRelativeTime(createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  // Only show Accept/Reject for request type
                  if (type == NotificationType.request)
                    Row(
                      children: [
                        if (onAccept != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade300,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: onAccept,
                            child: const Text("Accept"),
                          ),
                        const SizedBox(width: 5),
                        if (onReject != null)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade300,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: onReject,
                            child: const Text("Reject"),
                          ),
                      ],
                    ),

                  const SizedBox(height: 5),

                  // Only one Mark as Read button, always correct
                  if (onMarkAsRead != null)
                    TextButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onMarkAsRead,
                      child: const Text(
                        "Mark as read",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  // Text(
                  //   formatRelativeTime(notification.createdAt),
                  //   style: const TextStyle(fontSize: 12, color: Colors.grey),
                  // ),

                ],
              ),
            ),
          ],
        ),
      ),
    );


  }
}




