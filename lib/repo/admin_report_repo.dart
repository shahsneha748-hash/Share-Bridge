abstract class AdminReportRepo {
  Future<List<Map<String, dynamic>>> fetchReports();
  Future<void> updateReportStatus(String reportId, String status);
}