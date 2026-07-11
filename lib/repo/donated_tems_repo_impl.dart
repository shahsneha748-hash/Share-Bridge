import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/volunteer_request_model.dart';
import 'donated_item_repo.dart';

class DonatedItemsRepoImpl implements DonatedItemsRepo {
  final FirebaseFirestore firestore;
  DonatedItemsRepoImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<VolunteerRequestModel>> getDonatedItems(String donorId) {
    return firestore
        .collection('volunteer_requests')
        .where('donorId', isEqualTo: donorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return VolunteerRequestModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}