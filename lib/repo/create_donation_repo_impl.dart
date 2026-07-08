import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/create_donation_model.dart';
import 'create_donation_repo.dart';

class CreateDonationRepoImpl implements CreateDonationRepository {
  final FirebaseFirestore firestore;

  CreateDonationRepoImpl(this.firestore);

  @override
  Future<bool> submitDonation(CreateDonationModel model) async {
    try {
      await firestore.collection("donations").add({
        ...model.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'available',
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> createDonation(CreateDonationModel model) async {
    try {

      // Firebase creates the donation id automatically
      final docRef = firestore.collection("donations").doc();

      await docRef.set({
        ...model.toJson(),
        'donationId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'available',
      });

      return true;

    } catch (e) {
      print("Error creating donation: $e");
      return false;
    }
  }
}