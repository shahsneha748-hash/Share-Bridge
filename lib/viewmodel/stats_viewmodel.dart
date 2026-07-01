import 'package:flutter/material.dart';
import '../repo/stats_repo.dart';
import '../repo/stats_repo_impl.dart';

class StatsViewModel extends ChangeNotifier {
  final StatsRepo _repo = StatsRepoImpl();

  bool isLoading = false;

  // Users
  int totalUsers = 0;
  int bannedUsers = 0;
  int donorCount = 0;
  int receiverCount = 0;
  int volunteerCount = 0;
  int get activeUsers => totalUsers - bannedUsers;

  // Reports
  int totalReports = 0;
  int pendingReports = 0;
  int resolvedReports = 0;
  int userReports = 0;
  int donationReports = 0;
  int volunteerReports = 0;

  Future<void> fetchStats() async {
    isLoading = true;
    notifyListeners();

    try {
      final userStats = await _repo.fetchUserStats();
      totalUsers     = userStats['total'];
      bannedUsers    = userStats['banned'];
      donorCount     = userStats['donors'];
      receiverCount  = userStats['receivers'];
      volunteerCount = userStats['volunteers'];

      final reportStats  = await _repo.fetchReportStats();
      totalReports       = reportStats['total'];
      pendingReports     = reportStats['pending'];
      resolvedReports    = reportStats['resolved'];
      userReports        = reportStats['userReports'];
      donationReports    = reportStats['donationReports'];
      volunteerReports   = reportStats['volunteerReports'];
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}