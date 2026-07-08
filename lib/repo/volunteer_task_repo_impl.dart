import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/volunteer_task_model.dart';
import 'volunteer_task_repo.dart';


class VolunteerTaskRepoImpl implements VolunteerTaskRepo{


  final FirebaseFirestore firestore;


  VolunteerTaskRepoImpl({
    required this.firestore
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
      String status){

    return firestore
        .collection("volunteer_requests")
        .doc(taskId)
        .update({

      "status":status

    });

  }


}