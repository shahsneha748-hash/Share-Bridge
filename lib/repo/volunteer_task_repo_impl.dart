import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/volunteer_task_model.dart';
import 'volunteer_task_repo.dart';

class VolunteerTaskRepoImpl implements VolunteerTaskRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Stream<List<VolunteerTaskModel>> getAvailableTasks() {
    return firestore
        .collection('volunteer_tasks')
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return VolunteerTaskModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Stream<List<VolunteerTaskModel>> getMyTasks(String volunteerId) {
    return firestore
        .collection('volunteer_tasks')
        .where('assignedVolunteerId', isEqualTo: volunteerId)
        .orderBy('acceptedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return VolunteerTaskModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  @override
  Future<void> acceptTask({
    required String taskId,
    required String volunteerId,
  }) async {
    await firestore.collection('volunteer_tasks').doc(taskId).update({
      'status': 'accepted',
      'assignedVolunteerId': volunteerId,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completeTask(String taskId) async {
    await firestore.collection('volunteer_tasks').doc(taskId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }
}