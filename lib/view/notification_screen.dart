import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0XFF435944),
        foregroundColor: Colors.white,
        title: const Text("Notification",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
        actions: [
          SizedBox(
            width: 110,
            height: 30,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFFf2ead3),
                  foregroundColor: const Color(0XFF455b46),
                ),
                onPressed: () async {
                  final vm = context.read<NotificationViewModel>();
                  for (final n in vm.notifications) {
                    if (!n.isRead) {
                      await vm.markAllAsRead();
                    }
                  }
                },
                child: const Center(
                  child: Text("Mark as read",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, vm, child) {
          final now = DateTime.now();

          // 🔹 Alerts: only those created within the last 24 hours
          final alerts = vm.notifications.where((n) =>
          n.type == "alert" &&
              now.difference(n.createdAt).inHours < 24).toList();

          // 🔹 Today’s notifications (excluding alerts)
          final today = vm.notifications.where((n) {
            return n.type != "alert" &&
                n.createdAt.year == now.year &&
                n.createdAt.month == now.month &&
                n.createdAt.day == now.day;
          }).toList();

          // 🔹 Yesterday
          final yesterdayDate = now.subtract(const Duration(days: 1));
          final yesterday = vm.notifications.where((n) {
            return n.type != "alert" &&
                n.createdAt.year == yesterdayDate.year &&
                n.createdAt.month == yesterdayDate.month &&
                n.createdAt.day == yesterdayDate.day;
          }).toList();

          // 🔹 Older (group by actual date)
          final older = vm.notifications.where((n) {
            return n.type != "alert" &&
                n.createdAt.isBefore(yesterdayDate);
          }).toList();

          // Group older notifications by date
          final Map<String, List<NotificationModel>> groupedByDate = {};
          for (var n in older) {
            final formattedDate =
            DateFormat("MMMM d, yyyy").format(n.createdAt);
            groupedByDate.putIfAbsent(formattedDate, () => []).add(n);
          }

          return ListView(
            children: [
              if (alerts.isNotEmpty) ...[
                _sectionHeader("", color: Colors.red),
                ...alerts.map((n) => _notificationCard(n, vm)).toList(),
              ],
              if (today.isNotEmpty) ...[
                _sectionHeader("Today"),
                ...today.map((n) => _notificationCard(n, vm)).toList(),
              ],
              if (yesterday.isNotEmpty) ...[
                _sectionHeader("Yesterday"),
                ...yesterday.map((n) => _notificationCard(n, vm)).toList(),
              ],
              for (var entry in groupedByDate.entries) ...[
                _sectionHeader(entry.key),
                ...entry.value.map((n) => _notificationCard(n, vm)).toList(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title, {Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _notificationCard(NotificationModel n, NotificationViewModel vm) {
    if (n.type == "alert") {
      return Card(
        color: Colors.red[100],
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Colors.red),
        ),
        child: ListTile(
          leading: const Icon(Icons.warning, color: Colors.red),
          title: Text(n.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text(n.body,
              style: const TextStyle(color: Colors.red, fontSize: 15)),
          trailing: Text(
            DateFormat("HH:mm").format(n.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    return Card(
      color: n.isRead ? Colors.grey[200] : Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0XFF6a965b)),
      ),
      child: ListTile(
        leading: n.imageUrl != null
            ? Image.network(n.imageUrl!, height: 60, width: 60)
            : const Icon(Icons.notifications),
        title: Text(n.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        subtitle: Text(n.body),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat("d/M HH:mm").format(n.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            TextButton(
              onPressed: () async {
                await vm.markAllAsRead();
              },
              child: const Text("Mark as read"),
            ),
          ],
        ),
      ),
    );
  }
}

// Note: ⚡ Flow Recap
// Model → defines notification data. (Eg: Model = raw data only (like a database row).)
// Repo → fetches/saves notifications from Firestore. (Eg: repo = only defines what function exits with hiding implementation of functions. Eg: addUser, deleteUser, etc. so that MVVM architecture is clean)
// ViewModel → manages state, exposes clean methods.
// View → displays notifications, calls ViewModel methods.   (Eg: Notification Screen => Pure UI, listens to ViewModel via Provider.)