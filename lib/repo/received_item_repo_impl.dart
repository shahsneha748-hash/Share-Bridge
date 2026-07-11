import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/volunteer_request_model.dart';
import 'received_item_repo.dart';

class ReceivedItemsRepoImpl implements ReceivedItemsRepo {
  final FirebaseFirestore firestore;
  ReceivedItemsRepoImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<VolunteerRequestModel>> getReceivedItems(String receiverId) {
    return firestore
        .collection('volunteer_requests')
        .where('receiverId', isEqualTo: receiverId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return VolunteerRequestModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}