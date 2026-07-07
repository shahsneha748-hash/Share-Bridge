import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/volunteer_request_model.dart';
import 'volunteer_request_repo.dart';



class VolunteerRequestRepoImpl
    implements VolunteerRequestRepo {


  final FirebaseFirestore firestore;


  VolunteerRequestRepoImpl({
    FirebaseFirestore? firestore,
  })
      : firestore =
      firestore ?? FirebaseFirestore.instance;



  @override
  Future<void> createRequest(
      VolunteerRequestModel request
      ) async {


    await firestore
        .collection('volunteer_requests')
        .add({
      ...request.toMap(),
      "createdAt": FieldValue.serverTimestamp(),
    });

  }



  @override
  Stream<List<VolunteerRequestModel>>
  getVolunteerRequests(){


    return firestore
        .collection('volunteer_requests')
        .where(
        'status',
        isEqualTo: 'pending'
    )
        .snapshots()
        .map((snapshot){


      return snapshot.docs.map((doc){


        return VolunteerRequestModel.fromMap(
            doc.data(),
            doc.id
        );


      }).toList();


    });


  }



  @override
  Future<void> updateRequestStatus(
      String requestId,
      String status,
      ) async {


    await firestore
        .collection('volunteer_requests')
        .doc(requestId)
        .update({

      'status':status

    });


  }



}