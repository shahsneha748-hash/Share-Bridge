import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/notification_model.dart';
import '../model/volunteer_request_model.dart';
import 'notification_repo.dart';
import 'volunteer_request_repo.dart';

class VolunteerRequestRepoImpl implements VolunteerRequestRepo {

  final FirebaseFirestore firestore;
  final NotificationRepo notificationRepo;

  VolunteerRequestRepoImpl({
    FirebaseFirestore? firestore,
    required this.notificationRepo,
  }) : firestore = firestore ?? FirebaseFirestore.instance;


  @override
  Future<void> createRequest(VolunteerRequestModel request) async {

    // Create volunteer request
    await firestore.collection('volunteer_requests').add({
      ...request.toMap(),
      "createdAt": FieldValue.serverTimestamp(),
    });


    // Get approved volunteers accepting tasks
    final volunteers = await firestore
        .collection("volunteers")
        .where("status", isEqualTo: "Approved")
        .where("isAcceptingTasks", isEqualTo: true)
        .get();


    // Notify every volunteer
    for (final volunteer in volunteers.docs) {

      final volunteerId = volunteer.id;


      final notification = NotificationModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        senderId: request.donorId,

        receiverId: volunteerId,

        type: NotificationType.pickup,

        body:
        "A new donation delivery request is available. Check your tasks.",

        createdAt: DateTime.now(),

        isRead: false,

        senderName: request.donorName,

        postId: request.donationId,
      );


      await notificationRepo.sendNotification(notification);
    }
  }

  @override
  Stream<List<VolunteerRequestModel>> getVolunteerRequests() {
    return firestore
        .collection('volunteer_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return VolunteerRequestModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<bool> acceptRequest(String requestId, String volunteerId) async {
    final docRef = firestore.collection('volunteer_requests').doc(requestId);

    return firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) return false;

      final currentStatus = snapshot.data()?['status'];
      if (currentStatus != 'pending') {
        // Someone else already accepted/rejected it first
        return false;
      }

      transaction.update(docRef, {
        'status': 'accepted',
        'assignedVolunteerId': volunteerId,
        'volunteerId': volunteerId,
      });
      return true;
    });
  }

  @override
  Future<void> updateRequestStatus(String requestId, String status) async {
    await firestore.collection('volunteer_requests').doc(requestId).update({
      'status': status,
    });
  }

  @override
  Future<void> rejectRequest(String requestId, String volunteerId) async {
    await firestore.collection('volunteer_requests').doc(requestId).update({
      'rejectedBy': FieldValue.arrayUnion([volunteerId]),
    });
  }

  @override
  Future<void> confirmDelivery(String requestId) async {
    final docRef = firestore.collection('volunteer_requests').doc(requestId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final volunteerId = snapshot.data()?['assignedVolunteerId'] as String?;

      transaction.update(docRef, {'status': 'completed'});

      if (volunteerId != null && volunteerId.isNotEmpty) {
        final volunteerRef = firestore.collection('volunteers').doc(volunteerId);
        transaction.update(volunteerRef, {
          'completedTasksCount': FieldValue.increment(1),
        });
      }
    });
  }
}