import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Donations
  int totalDonations = 0;
  int availableDonations = 0;
  int takenDonations = 0;
  int foodDonations = 0;
  int clothesDonations = 0;
  int stationeryDonations = 0;
  int othersDonations = 0;

  // Volunteers
  int pendingVolunteers = 0;
  int approvedVolunteers = 0;
  int rejectedVolunteers = 0;

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

      await _fetchDonationStats();
      await _fetchVolunteerStats();
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchDonationStats() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('donations').get();

    totalDonations = snapshot.docs.length;
    availableDonations = 0;
    takenDonations = 0;
    foodDonations = 0;
    clothesDonations = 0;
    stationeryDonations = 0;
    othersDonations = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if (data['isDonated'] == true) {
        takenDonations++;
      } else {
        availableDonations++;
      }

      final category = (data['category'] ?? '').toString().toLowerCase();
      switch (category) {
        case 'food':
          foodDonations++;
          break;
        case 'clothes':
          clothesDonations++;
          break;
        case 'stationery':
          stationeryDonations++;
          break;
        default:
          othersDonations++;
      }
    }
  }

  Future<void> _fetchVolunteerStats() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('volunteers').get();

    pendingVolunteers = 0;
    approvedVolunteers = 0;
    rejectedVolunteers = 0;

    for (final doc in snapshot.docs) {
      final status = (doc.data()['status'] ?? 'Pending').toString();
      if (status == 'Approved') {
        approvedVolunteers++;
      } else if (status == 'Rejected' || status == 'Suspended') {
        rejectedVolunteers++;
      } else {
        pendingVolunteers++;
      }
    }
  }
}