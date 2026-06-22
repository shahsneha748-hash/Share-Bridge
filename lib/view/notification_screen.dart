// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:sharebridge/model/notification_model.dart';
// import 'package:sharebridge/viewmodel/notification_view_model.dart';
//
// class NotificationScreen extends StatelessWidget {
//   final NotificationViewModel vm;
//
//   const NotificationScreen({super.key, required this.vm});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Notifications")),
//       body: ListView.builder(
//         itemCount: vm.notifications.length,
//         itemBuilder: (context, index) {
//           final notification = vm.notifications[index];
//
//           if (notification.type == "request") {
//             return NotificationCard(
//               title: "Donation Request",
//               description: notification.description,
//               onAccept: () => vm.sendNotification("accepted", notification.receiverId),
//               onReject: () => vm.sendNotification("rejected", notification.receiverId),
//             );
//           } else if (notification.type == "pickup") {
//             return NotificationCard(
//               title: "Pickup Scheduled",
//               description: notification.description,
//               numberField: notification.pickupNumber,
//               onEdit: () => vm.editPickupNotification(notification.id),
//             );
//           } else {
//             return NotificationCard(
//               title: notification.title,
//               description: notification.description,
//             );
//           }
//         },
//       ),
//     );
//   }
// }


// Note: ⚡ Flow Recap
// Model → defines notification data. (Eg: Model = raw data only (like a database row).)
// Repo → fetches/saves notifications from Firestore. (Eg: repo = only defines what function exits with hiding implementation of functions. Eg: addUser, deleteUser, etc. so that MVVM architecture is clean)
// ViewModel → manages state, exposes clean methods.
// View → displays notifications, calls ViewModel methods.   (Eg: Notification Screen => Pure UI, listens to ViewModel via Provider.)