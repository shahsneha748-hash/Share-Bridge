import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/admin_volunteer_model.dart';
import 'admin_volunteer_repo.dart';

class AdminVolunteerRepoImpl implements AdminVolunteerRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<AdminVolunteerModel>> fetchVolunteers() async {
    final snapshot = await _firestore.collection('volunteers').get();

    List<AdminVolunteerModel> volunteers = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      String name = 'Unknown User';
      String email = 'N/A';
      String phone = 'N/A';
      String address = 'N/A';

      final userId = data['userId'] ?? '';
      if (userId.isNotEmpty) {
        final userDoc =
        await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          name = userData?['fullName'] ?? 'Unknown User';
          email = userData?['email'] ?? 'N/A';
          phone = userData?['phone'] ?? 'N/A';
          address = userData?['address'] ?? 'N/A';
        }
      }

      volunteers.add(AdminVolunteerModel.fromMap(
        data,
        doc.id,
        name: name,
        email: email,
        phone: phone,
        address: address,
      ));
    }

    return volunteers;
  }

  @override
  Future<void> updateVolunteerStatus(String volunteerId, String status) async {
    await _firestore
        .collection('volunteers')
        .doc(volunteerId)
        .update({'status': status});
  }
}