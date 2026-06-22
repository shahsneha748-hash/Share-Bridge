// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import 'package:sharebridge/model/pickup_notification_model.dart';
// import 'package:sharebridge/service/notification_service.dart';
// import 'package:sharebridge/view/homescreentest.dart';
// import 'package:sharebridge/viewmodel/pickup_notification_view_model.dart';
//
// class PickupNotificationScreen extends StatefulWidget {
//
//   const PickupNotificationScreen({super.key});
//
//   @override
//   State<PickupNotificationScreen> createState() => _PickupNotificationScreenState();
// }
//
// class _PickupNotificationScreenState extends State<PickupNotificationScreen> {
//   final TitleController = TextEditingController();
//   final DescriptionController = TextEditingController();
//   final PhoneController = TextEditingController();
//
//
//   NotificationService notificationService = NotificationService();
//
//   @override
//   void initState() {
//     super.initState();
//
//     // When app is launched from terminated state
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         print("Terminated launch: $message");
//         // Navigate if needed
//       }
//     });
//
//     // Get FCM token
//     FirebaseMessaging.instance.getToken().then((value) {
//       print("📱 FCM Token: $value");
//     });
//
//     // Foreground messages
//     FirebaseMessaging.onMessage.listen((message) {
//       if (message.notification != null) {
//         print("Foreground: ${message.notification!.title}");
//         print("Foreground: ${message.notification!.body}");
//
//       }
//
//       // Show local popup
//       NotificationService.displayFcm(
//         notification: message.notification!,
//         buildContext: context,
//       );
//     });
//
//     // Background (when user taps notification)
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       print("Background tap: $message");
//       // Navigate if needed
//     });
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Pickup Notification"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Column(
//               children: [
//                 // CachedNetworkImage(
//                 //   height: 100,width: 100,
//                 //   imageUrl: data.imageUrl.toString(),
//                 //   placeholder: (context, url) =>
//                 //   const Center(child: CircularProgressIndicator()),
//                 //   errorWidget: (context, url, error) =>
//                 //   const Icon(Icons.error),
//                 // ),
//                 Image.asset("assets/images/Mila1.png"),   // here we must add profile picture from sneha
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                   child: TextFormField(
//                     controller: TitleController,
//                     decoration: InputDecoration(
//                         hint: Padding(
//                           padding: const EdgeInsets.only(left: 5),
//                           child: Text("Title", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 18)),
//                         ),
//                         fillColor: Colors.white,
//                         filled: true,
//                         enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(25)),
//                         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))
//
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                   child: TextFormField(
//                     controller: DescriptionController,
//                     decoration: InputDecoration(
//                         hint: Padding(
//                           padding: const EdgeInsets.only(left: 5),
//                           child: Text("Description", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 18)),
//                         ),
//                         fillColor: Colors.white,
//                         filled: true,
//                         enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(25)),
//                         focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))
//
//                     ),
//                   ),
//                 ),
//                   Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//             child: TextFormField(
//               controller: PhoneController,
//               decoration: InputDecoration(
//                   hint: Padding(
//                     padding: const EdgeInsets.only(left: 5),
//                     child: Text("Reciever's Number", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 18)),
//                   ),
//                   fillColor: Colors.white,
//                   filled: true,
//                   enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(25)),
//                   focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(25))
//
//               ),
//             ),
//                   ),
//
//                 SizedBox(height: 20,),
//
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (TitleController.text.trim().isEmpty ||
//                         DescriptionController.text.trim().isEmpty ||
//                         PhoneController.text.trim().isEmpty) {
//                       Fluttertoast.showToast(msg: "All fields must be filled");
//                       return;
//                     }
//
//                     // 1. Build model
//                     final model = PickupNotificationModel(
//                       id: FirebaseAuth.instance.currentUser!.uid,
//                       title: TitleController.text.trim(),
//                       description: DescriptionController.text.trim(),
//                       targetRole: "volunteer",
//                       senderId: FirebaseAuth.instance.currentUser!.uid,
//                       receiverId: PhoneController.text.trim(),
//                       senderName: FirebaseAuth.instance.currentUser!.displayName,
//                       profilePicture: "assets/images/Mila1.png",
//                       createdAt: DateTime.now(),
//                       isRead: false, // ✅ start unread so badge increases
//                     );
//
//                     final vm = context.read<PickupNotificationViewModel>();
//
//                     // 2. Save to Firestore
//                     final success = await vm.addPickupNotification(model);
//
//                     if (success) {
//                       // 3. Show popup notification
//                       await NotificationService.display(
//                         title: model.title,
//                         body: model.description,
//                         payload: "pickup_notification_screen",
//                         buildContext: context,
//                       );
//
//                       // 4. Navigate to HomeScreen (optional)
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => const Homescreentest()),
//                       );
//
//                       Fluttertoast.showToast(msg: "Notification sent successfully");
//                     } else {
//                       Fluttertoast.showToast(msg: "Notification failed to send");
//                     }
//                   },
//                   child: const Text("Send Notification"),
//                 )
//
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
