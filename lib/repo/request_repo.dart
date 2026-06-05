import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/request_model.dart';

class RequestRepo {
  final _col = FirebaseFirestore.instance.collection('requests');

  Future<void> createRequest(RequestModel request) async {
    await _col.doc(request.id).set(request.toMap());
  }

  Future<void> updateStatus(String id, RequestStatus status, {String? scheduledTime}) async {
    await _col.doc(id).update({
      'status': status.name,
      if (scheduledTime != null) 'scheduledTime': scheduledTime,
    });
  }

  Future<void> deleteRequest(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<RequestModel>> streamRequests() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => RequestModel.fromMap(d.data()))
        .toList());
  }
}