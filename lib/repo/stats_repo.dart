abstract class StatsRepo {
  Future<Map<String, dynamic>> fetchUserStats();
  Future<Map<String, dynamic>> fetchReportStats();
}