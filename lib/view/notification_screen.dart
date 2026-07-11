import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/components/notification_card.dart';
import 'package:sharebridge/view/request_system_screen.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';
import '../model/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String selectedCategory = "All";
  bool _urgentExpanded = false;
  static const int _urgentCollapsedCount = 2;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();
    final grouped = vm.groupNotifications();
    final sections = ["Urgent", "Today", "Yesterday"];

    // Filter notifications based on category
    final filtered = selectedCategory == "All"
        ? vm.notifications
        : vm.notifications.where((n) => n.type == NotificationType.request).toList();

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
                vm.markAllAsRead();
              },
              child: const Text(
                "Mark as Read",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [

          // Category filter buttons (same design as Saved Items)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                buildFilterButton("All"),
                buildFilterButton("Requests"),
              ],
            ),
          ),

          const SizedBox(height: 15),

          if (selectedCategory == "All")
          // Show grouped sections (Urgent, Today, Yesterday)
            ...sections.map((section) {
              final items = grouped[section] ?? [];
              if (items.isEmpty) return const SizedBox.shrink();

              var visibleItems = items;
              final isUrgentSection = section == "Urgent";
              if (isUrgentSection &&
                  !_urgentExpanded &&
                  items.length > _urgentCollapsedCount) {
                visibleItems = items.take(_urgentCollapsedCount).toList();
              }

              final cards = visibleItems.map<Widget>((n) {
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
              }).toList();

              if (isUrgentSection && items.length > _urgentCollapsedCount) {
                cards.add(
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() => _urgentExpanded = !_urgentExpanded);
                      },
                      child: Text(
                        _urgentExpanded
                            ? 'See less ▲'
                            : 'See more (${items.length - _urgentCollapsedCount}) ▼',
                        style: const TextStyle(
                          color: Color(0xFF3A5C2E),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Column(children: cards),
                ],
              );
            })
          else
          // Show only Requests category
            ...filtered.map((n) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RequestSystemScreen(),
                      ),
                    );
                  },
                  child: NotificationCard(
                    notification: n,
                    type: n.type,
                    body: n.body ?? "",
                    createdAt: n.createdAt,
                    profilePicture: n.profilePicture ?? "",
                    onMarkAsRead: () => vm.markAsRead(n.id),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget buildFilterButton(String category) {
    final isSelected = selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isSelected ? const Color(0XFF435944) : const Color(0XFFF2EAD3),
          foregroundColor:
          isSelected ? Colors.white : const Color(0XFF435944),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        onPressed: () {
          setState(() {
            selectedCategory = category;
          });
        },
        child: Text(category),
      ),
    );
  }
}

