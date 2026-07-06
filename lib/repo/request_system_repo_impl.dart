import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/request_system_model.dart';
import 'request_system_repo.dart';

class RequestSystemRepoImpl implements RequestSystemRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _collection => _firestore.collection('requests');
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _donationsCollection => _firestore.collection('donations');

  @override
  Future<void> createRequest(RequestSystemModel request) async {
    await _collection.add(request.toMap());
  }

  @override
  Stream<List<RequestSystemModel>> getRequests() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final donorIds = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['donorId'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();

      final Map<String, String> donorNames = {};
      if (donorIds.isNotEmpty) {
        final userDocs = await Future.wait(
          donorIds.map((id) => _usersCollection.doc(id).get()),
        );
        for (final userDoc in userDocs) {
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;
            donorNames[userDoc.id] = data['fullName'] ?? '';
          }
        }
      }

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final donorId = data['donorId'] as String? ?? '';
        return RequestSystemModel.fromFirestore(
          data,
          doc.id,
          donorName: donorNames[donorId] ?? '',
        );
      }).toList();
    });
  }

  @override
  Future<void> updateStatus(String requestId, String status) async {
    await _collection.doc(requestId).update({'status': status});

    // When a donor accepts, mark the linked donation as claimed
    // so it disappears from browse/dashboard (but stays in DB for
    // the receiver/donor's "My Donations" history).
    if (status == 'accepted') {
      final requestDoc = await _collection.doc(requestId).get();
      final data = requestDoc.data() as Map<String, dynamic>?;
      final donationId = data?['donationId'] as String?;

      if (donationId != null && donationId.isNotEmpty) {
        await _donationsCollection.doc(donationId).update({
          'status': 'claimed',
          'acceptedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}