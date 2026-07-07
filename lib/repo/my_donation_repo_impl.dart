import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharebridge/model/donation_record.dart';
import 'package:sharebridge/repo/my_donation_repo.dart';

class MyDonationsRepoImpl implements MyDonationsRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Stream<List<DonationRecord>> getDonationsForUser(String userId) {
    return firestore
        .collection("donations")
        .where("userId", isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => DonationRecord.fromFirestore(doc.id, doc.data()))
          .toList();

      // Sorted client-side (newest first) — avoids needing a composite
      // Firestore index for where + orderBy on different fields.
      records.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return records;
    });
  }
}