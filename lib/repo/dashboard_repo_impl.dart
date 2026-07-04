import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/dashboard_model.dart';
import 'dashboard_repo.dart';

class DashboardRepoImpl implements DashboardRepo {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  @override
  Stream<DashboardModel> getDashboardData() {
    return firestore
        .collection("donations")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return DashboardModel(
        donations: snapshot.docs.map((doc) {
          return {
            "id": doc.id,
            ...doc.data(),
          };
        }).toList(),
      );
    });
  }
}