import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/create_donation_model.dart';

class DonationRepo {
  final _col = FirebaseFirestore.instance.collection('donations');

  Future<void> createDonation(DonationModel donation) async {
    await _col.doc(donation.id).set(donation.toMap());
  }

  Future<void> updateDonation(DonationModel donation) async {
    await _col.doc(donation.id).update(donation.toMap());
  }

  Future<void> deleteDonation(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> markAsDonated(String id, bool isDonated) async {
    await _col.doc(id).update({'isDonated': isDonated});
  }

  Stream<List<DonationModel>> streamDonations() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => DonationModel.fromMap(d.data()))
        .toList());
  }

  Future<List<DonationModel>> getDonations() async {
    final snap = await _col.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => DonationModel.fromMap(d.data())).toList();
  }
}