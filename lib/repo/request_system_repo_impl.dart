import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/create_donation_model.dart';
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
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return _collection
        .where(Filter.or(
      Filter('donorId', isEqualTo: currentUid),
      Filter('userId', isEqualTo: currentUid),
    ))
        .snapshots()
        .asyncMap((snapshot) async {
      final donorIds = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['donorId'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet();

      final userIds = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet();

      final allIds = {...donorIds, ...userIds}.toList();
      final Map<String, String> namesById = {};
      final Map<String, String> picsById = {};

      if (allIds.isNotEmpty) {
        final userDocs = await Future.wait(
          allIds.map((id) => _usersCollection.doc(id).get()),
        );
        for (final userDoc in userDocs) {
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;
            namesById[userDoc.id] = data['fullName'] ?? '';
            picsById[userDoc.id] = data['profilePicture'] ?? '';
          }
        }
      }

      final results = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final donorId = data['donorId'] as String? ?? '';
        final userId = data['userId'] as String? ?? '';
        return RequestSystemModel.fromFirestore(
          data,
          doc.id,
          donorName: namesById[donorId] ?? '',
          userName: namesById[userId],
          userProfilePicture: picsById[userId],
        );
      }).toList();

      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return results;
    });
  }

  @override
  Future<void> updateStatus(String requestId, String status) async {
    await _collection.doc(requestId).update({'status': status});

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

  @override
  Future<CreateDonationModel?> getDonationById(String id) async {
    try {
      final doc = await _donationsCollection.doc(id).get();
      if (!doc.exists) return null;
      return CreateDonationModel.fromMap(
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception("Failed to fetch donation: $e");
    }
  }
}