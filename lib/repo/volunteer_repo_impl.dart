import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/volunteer_model.dart';
import 'volunteer_repo.dart';

class VolunteerRepoImpl implements VolunteerRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> submitVolunteer(VolunteerModel model) async {
    await firestore
        .collection("volunteers")
        .doc(model.userId)
        .set(model.toMap());
  }

  @override
  Future<String> getStatus(String userId) async {
    final doc =
    await firestore.collection("volunteers").doc(userId).get();

    if (!doc.exists) return "none";

    return doc.data()?['status'] ?? "none";
  }

  @override
  Stream<String> getStatusStream(String userId) {
    return FirebaseFirestore.instance
        .collection("volunteers")
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?["status"] ?? "none");
  }


}