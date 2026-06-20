import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/volunteer_model.dart';
import 'volunteer_repo.dart';

class VolunteerRepoImpl implements VolunteerRepo {

  final FirebaseFirestore firestore;

  VolunteerRepoImpl({
    required this.firestore,
  });

  @override
  Stream<List<VolunteerTaskModel>> getAvailableTasks() {

    return firestore
        .collection('donations')
        .where('needsVolunteer', isEqualTo: true)
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return VolunteerTaskModel.fromJson(
          doc.data(),
          doc.id,
        );

      }).toList();
    });
  }

  @override
  Stream<List<VolunteerTaskModel>> getMyTasks(
      String volunteerId) {

    return firestore
        .collection('donations')
        .where('volunteerId', isEqualTo: volunteerId)
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return VolunteerTaskModel.fromJson(
          doc.data(),
          doc.id,
        );

      }).toList();
    });
  }

  @override
  Future<void> acceptTask({
    required String donationId,
    required String volunteerId,
  }) async {

    final docRef =
    firestore.collection('donations').doc(donationId);

    await firestore.runTransaction((transaction) async {

      final snapshot =
      await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Task not found');
      }

      final data = snapshot.data()!;

      if (data['status'] != 'open') {
        throw Exception(
            'Task already accepted');
      }

      transaction.update(docRef, {
        'status': 'assigned',
        'volunteerId': volunteerId,
      });
    });
  }
}