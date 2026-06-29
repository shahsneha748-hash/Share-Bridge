import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_report_repo.dart';

class AdminReportRepoImpl implements AdminReportRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchReports() async {
    final snapshot = await _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => {
      ...doc.data(),
      'id': doc.id,
    }).toList();
  }

  @override
  Future<void> updateReportStatus(String reportId, String status) async {
    await _firestore
        .collection('reports')
        .doc(reportId)
        .update({'status': status});
  }
}