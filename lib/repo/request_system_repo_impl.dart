import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharebridge/repo/request_system_repo.dart';
import '../model/request_system_model.dart';

class DonationRequestRepositoryImpl implements DonationRequestRepository {
  final FirebaseFirestore _firestore;

  DonationRequestRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _collection =>
      _firestore.collection('donations');

  @override
  Stream<List<DonationRequestModel>> getRequests() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => DonationRequestModel.fromFirestore(
      doc.data() as Map<String, dynamic>,
      doc.id,
    ))
        .toList());
  }

  @override
  Future<void> updateStatus(String requestId, String status) async {
    await _collection.doc(requestId).update({'status': status});
  }
}