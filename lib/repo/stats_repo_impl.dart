import 'package:cloud_firestore/cloud_firestore.dart';
import 'stats_repo.dart';

class StatsRepoImpl implements StatsRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>> fetchUserStats() async {
    final snapshot = await _firestore.collection('users').get();
    final docs = snapshot.docs;

    return {
      'total': docs.length,
      'banned': docs.where((d) => d.data()['isBanned'] == true).length,
      'donors': docs.where((d) => d.data()['role'] == 'donor').length,
      'receivers': docs.where((d) => d.data()['role'] == 'receiver').length,
      'volunteers': docs.where((d) => d.data()['role'] == 'volunteer').length,
    };
  }

  @override
  Future<Map<String, dynamic>> fetchReportStats() async {
    final snapshot = await _firestore.collection('reports').get();
    final docs = snapshot.docs;

    return {
      'total': docs.length,
      'pending': docs.where((d) => d.data()['status'] == 'pending').length,
      'resolved': docs.where((d) =>
      d.data()['status'] == 'actionTaken' ||
          d.data()['status'] == 'dismissed').length,
      'userReports': docs.where((d) => d.data()['reportType'] == 'A User').length,
      'donationReports': docs.where((d) => d.data()['reportType'] == 'A Donation Post').length,
      'volunteerReports': docs.where((d) => d.data()['reportType'] == 'A Volunteer').length,
    };
  }
}