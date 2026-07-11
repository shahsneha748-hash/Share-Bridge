import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharebridge/viewmodel/admin_report_viewmodel.dart';

void main() {
  group('AdminReport.fromMap', () {
    test('parses a user report correctly', () {
      final map = {
        'id': 'report123',
        'reportedName': 'Tommy Hilfiger',
        'reportedId': 'user456',
        'reportType': 'A User',
        'reason': 'Spam/Fraud',
        'details': 'This user is a fraud',
        'reporterName': 'Anney Rai',
        'isAnonymous': false,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      };

      final report = AdminReport.fromMap(map);

      expect(report.id, 'report123');
      expect(report.reportedName, 'Tommy Hilfiger');
      expect(report.reportedId, 'user456');
      expect(report.reason, 'Spam/Fraud');
      expect(report.category, ReportCategory.user);
      expect(report.status, ReportStatus.pending);
      expect(report.isAnonymous, false);
    });

    test('defaults to Unknown when name is missing', () {
      final map = <String, dynamic>{
        'id': 'report999',
        'status': 'pending',
      };

      final report = AdminReport.fromMap(map);

      expect(report.reportedName, 'Unknown');
      expect(report.reportedInitial, 'U');
    });

    test('parses status correctly', () {
      final map = {
        'id': 'r1',
        'reportedName': 'Test',
        'status': 'dismissed',
      };

      final report = AdminReport.fromMap(map);

      expect(report.status, ReportStatus.dismissed);
    });
  });
}