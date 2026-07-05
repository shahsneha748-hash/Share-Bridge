import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';
import 'package:provider/provider.dart';

/// Single card widget
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final NotificationType type;
  final String body;
  final DateTime createdAt;
  final String? profilePicture;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.type,
    required this.body,
    required this.createdAt,
    this.profilePicture,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    ShapeBorder cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Colors.grey),
    );
    double cardElevation = 2;

    switch (type) {
      case NotificationType.request:
        cardElevation = 5;
        break;
      case NotificationType.volunteer_request:
        cardElevation = 5;
        bgColor = Colors.white;
        cardShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        );
        break;
      case NotificationType.alert:
        bgColor = const Color(0xFFeed2d2);
        cardShape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFe8a4a4)),
        );
        cardElevation = 6;
        break;
      default:
        break;
    }

    Widget buildProfileImage(String? profilePicture) {
      if (profilePicture == null || profilePicture.isEmpty) {
        return const CircleAvatar(radius: 40, child: Icon(Icons.person));
      }
      if (profilePicture.startsWith("http")) {
        return CircleAvatar(radius: 40, backgroundImage: NetworkImage(profilePicture));
      }
      if (profilePicture.startsWith("/")) {
        return CircleAvatar(radius: 40, backgroundImage: FileImage(File(profilePicture)));
      }
      return CircleAvatar(radius: 40, backgroundImage: AssetImage(profilePicture));
    }

    String formatRelativeTime(DateTime createdAt) {
      final now = DateTime.now();
      final diff = now.difference(createdAt);

      if (diff.inMinutes < 60) return "${diff.inMinutes}m";
      if (diff.inHours < 24) return "${diff.inHours}h";
      if (diff.inDays < 30) return "${diff.inDays}d";
      return "30d";
    }

    return Card(
      color: bgColor,
      shape: cardShape,
      elevation: cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildProfileImage(profilePicture),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(body),
                  Text(
                    formatRelativeTime(createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),

                  // 🔑 Accept/Reject buttons for volunteer request
                  if (notification.type == NotificationType.volunteer_request)
                    Consumer<NotificationViewModel>(
                      builder: (context, vm, _) {
                        final decision = vm.getDecision(notification.id);

                        return Row(
                          children: [
                            ElevatedButton(
                              onPressed: decision == VolunteerDecision.accepted
                                  ? null // disable once accepted
                                  : () async {
                                final success = await vm.acceptVolunteer(notification);
                                if (success) {
                                  await NotificationService.display(
                                    body: "${notification.senderName} has accepted your volunteering request.",
                                    createdAt: DateTime.now(),
                                    payload: "notification_screen",
                                    buildContext: context,
                                  );
                                  Fluttertoast.showToast(msg: "Notification sent successfully");
                                } else {
                                  Fluttertoast.showToast(msg: "Failed to send notification");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: decision == VolunteerDecision.accepted
                                    ? Colors.green.shade700
                                    : Colors.green.shade400,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                decision == VolunteerDecision.accepted ? "Accepted" : "Accept",
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                final success = await vm.rejectVolunteer(notification);
                                if (success) {
                                  await NotificationService.display(
                                    body: "${notification.senderName} has rejected your volunteering request.",
                                    createdAt: DateTime.now(),
                                    payload: "notification_screen",
                                    buildContext: context,
                                  );
                                  Fluttertoast.showToast(msg: "Notification sent successfully");
                                } else {
                                  Fluttertoast.showToast(msg: "Failed to send notification");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: decision == VolunteerDecision.rejected
                                    ? Colors.red.shade700
                                    : Colors.red.shade400,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                decision == VolunteerDecision.rejected ? "Rejected" : "Reject",
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 5),

                  if (onMarkAsRead != null)
                    InkWell(
                      onTap: notification.isRead ? null : onMarkAsRead,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          notification.isRead ? "Read" : "Mark as read",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: notification.isRead ? Colors.grey : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List widget with grouping + vanish rules
class NotificationList extends StatelessWidget {
  final List<NotificationCard> allCards;

  const NotificationList({super.key, required this.allCards});

  List<NotificationCard> _filterCards(List<NotificationCard> cards) {
    final now = DateTime.now();

    return cards.where((card) {
      if (card.type == NotificationType.alert) {
        return now.isBefore(card.createdAt.add(const Duration(days: 1)));
      } else {
        return now.isBefore(card.createdAt.add(const Duration(days: 30)));
      }
    }).toList();
  }

  Map<String, List<NotificationCard>> _groupCards(List<NotificationCard> cards) {
    final now = DateTime.now();
    final Map<String, List<NotificationCard>> grouped = {};

    for (var card in cards) {
      final diff = now.difference(card.createdAt);

      String sectionTitle;
      if (diff.inDays == 0) {
        sectionTitle = "Today";
      } else if (diff.inDays == 1) {
        sectionTitle = "Yesterday";
      } else {
        sectionTitle = "${card.createdAt.day}/${card.createdAt.month}/${card.createdAt.year}";
      }

      grouped.putIfAbsent(sectionTitle, () => []).add(card);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final visibleCards = _filterCards(allCards);
    final groupedCards = _groupCards(visibleCards);
    final sectionTitles = groupedCards.keys.toList();

    return ListView.builder(
      itemCount: sectionTitles.length,
      itemBuilder: (context, index) {
        final title = sectionTitles[index];
        final cards = groupedCards[title]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...cards,
          ],
        );
      },
    );
  }
}







