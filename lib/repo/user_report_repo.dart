abstract class UserReportRepo {
  Future<void> submitReport(Map<String, dynamic> reportData);
}