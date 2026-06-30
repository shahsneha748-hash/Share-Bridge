import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/request_system_model.dart';

class RequestSystemRepo {
  final _db = FirebaseFirestore.instance.collection("requests");

  Future<void> add(RequestSystemModel model) async {
    await _db.add(model.toMap());
  }

  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }

  Stream<List<RequestSystemModel>> getAll() {
    return _db.snapshots().map((snap) =>
        snap.docs.map((e) => RequestSystemModel.fromMap(e.data())).toList());
  }
}