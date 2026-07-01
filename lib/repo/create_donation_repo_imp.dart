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
        'status': 'pending',
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}