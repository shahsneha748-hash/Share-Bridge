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
    // trim() guards against stray whitespace like "Approved " breaking
    // exact-match checks elsewhere in the app.
    return (doc.data()?['status'] as String? ?? "none").trim();
  }

  @override
  Stream<String> getStatusStream(String userId) {
    return FirebaseFirestore.instance
        .collection("volunteers")
        .doc(userId)
        .snapshots()
        .map((doc) => (doc.data()?["status"] as String? ?? "none").trim());
  }

  // --- new: donor-side assignment ---

  @override
  Stream<List<VolunteerModel>> watchAvailableApprovedVolunteers() {
    return firestore
        .collection("volunteers")
        .where("status", isEqualTo: "Approved")
        .where("isAcceptingTasks", isEqualTo: true)
        .orderBy("rating", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => VolunteerModel.fromMap(doc.data()))
        .toList());
  }

  @override
  Future<void> setAcceptingTasks(String userId, bool value) async {
    await firestore
        .collection("volunteers")
        .doc(userId)
        .update({"isAcceptingTasks": value});
  }

  @override
  Stream<VolunteerModel> watchProfile(String userId) {
    return firestore
        .collection("volunteers")
        .doc(userId)
        .snapshots()
        .map((doc) => VolunteerModel.fromMap(doc.data() ?? {'userId': userId}));
  }
}