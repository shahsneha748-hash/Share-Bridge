import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_report_repo.dart';

class UserReportRepoImpl implements UserReportRepo {
  final _col = FirebaseFirestore.instance.collection('reports');
  final _notifications = FirebaseFirestore.instance.collection('admin_notifications');

  @override
  Future<void> submitReport(Map<String, dynamic> reportData) async {
    // Save report
    await _col.add(reportData);

    // Save admin notification
    await _notifications.add({
      'type': 'new_report',
      'title': 'New Report Submitted',
      'body': '${reportData['isAnonymous'] == true ? 'Anonymous' : reportData['reporterName']} reported ${reportData['reportedName']} for ${reportData['reason']}',
      'isRead': false,
      'createdAt': DateTime.now(),
    });
  }
}