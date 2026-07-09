import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/service/expiry_alert_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/create_donation_model.dart';
import 'create_donation_repo.dart';

class CreateDonationRepoImpl implements CreateDonationRepository {
  final FirebaseFirestore firestore;

  CreateDonationRepoImpl(this.firestore);


  @override
  Future<bool> submitDonation(CreateDonationModel model) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      String donorId = '';
      String donorName = 'Unknown';

      if (currentUser != null) {
        donorId = currentUser.uid;
        final userDoc = await firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
        donorName = userDoc.data()?['fullName'] ?? 'Unknown';
      }

      await firestore.collection("donations").add({
        ...model.toMap(),
        'donorId': donorId,
        'donorName': donorName,
        'userId': donorId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'available',
      });

      // ← Trigger expiry check immediately after posting
      if (donorId.isNotEmpty) {
        await ExpiryAlertService.checkAndCreateAlerts(donorId);
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}