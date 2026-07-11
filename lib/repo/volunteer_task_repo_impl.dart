import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/volunteer_task_model.dart';
import 'volunteer_task_repo.dart';


import '../model/notification_model.dart';
import '../repo/notification_repo.dart';


class VolunteerTaskRepoImpl implements VolunteerTaskRepo{

  final FirebaseFirestore firestore;
  final NotificationRepo notificationRepo;

  VolunteerTaskRepoImpl({
    required this.firestore,
    required this.notificationRepo,
  });


  @override
  Stream<List<VolunteerTaskModel>> getVolunteerTasks(
      String volunteerId){

    return firestore
        .collection("volunteer_requests")
        .where(
        "volunteerId",
        isEqualTo: volunteerId
    )
        .snapshots()
        .map((snapshot){

      return snapshot.docs.map((doc){

        return VolunteerTaskModel.fromMap(
            doc.id,
            doc.data()
        );

      }).toList();

    });

  }



  @override
  Future<void> updateTaskStatus(
      String taskId,
      String status) async {

    final docRef =
    firestore.collection("volunteer_requests").doc(taskId);


    final snapshot = await docRef.get();

    if (!snapshot.exists) return;


    final data = snapshot.data()!;


    await docRef.update({
      "status": status
    });


    // Send notification only when accepted
    if (status == "accepted") {

      final notification = NotificationModel(

        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        senderId: data["volunteerId"] ?? "",

        receiverId: data["donorId"],

        type: NotificationType.request_accepted,

        body:
        "${data["volunteerName"] ?? "A volunteer"} accepted your delivery request.",

        createdAt: DateTime.now(),

        isRead: false,

        senderName:
        data["volunteerName"] ?? "Volunteer",

        postId:
        data["donationId"] ?? "",
      );


      await notificationRepo.sendNotification(notification);
    }
  }

  @override
  Future<void> updateTaskLocation(
      String taskId,
      double latitude,
      double longitude,
      ) {
    return firestore.collection("volunteer_requests").doc(taskId).update({
      "currentLocation": {
        "lat": latitude,
        "lng": longitude,
      },
      "locationUpdatedAt": FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unacceptTask(String taskId) {
    return firestore.collection("volunteer_requests").doc(taskId).update({
      "status": "pending",
      "volunteerId": FieldValue.delete(),
      "assignedVolunteerId": FieldValue.delete(),
    });
  }


}