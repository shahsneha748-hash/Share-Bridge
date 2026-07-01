import 'package:cloud_firestore/cloud_firestore.dart';
import 'donation_admin_repo.dart';

class DonationAdminRepoImpl implements DonationAdminRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchDonations() async {
    final snapshot = await _firestore.collection('donations').get();

    // Fetch all users once
    final usersSnapshot = await _firestore.collection('users').get();
    final usersMap = {
      for (var doc in usersSnapshot.docs)
        doc.id: doc.data()['fullName'] as String? ?? 'Unknown'
    };

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final userId = data['userId'] as String? ?? '';
      return {
        ...data,
        'id': doc.id,
        'donorName': usersMap[userId] ?? 'Unknown',
      };
    }).toList();
  }

  @override
  Future<void> removeDonation(String donationId) async {
    await _firestore.collection('donations').doc(donationId).delete();
  }
}