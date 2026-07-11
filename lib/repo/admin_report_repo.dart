abstract class AdminReportRepo {
  Future<List<Map<String, dynamic>>> fetchReports();
  Future<void> updateReportStatus(String reportId, String status);
  Future<void> banReportedUser(String reportedId, String reportId);
}