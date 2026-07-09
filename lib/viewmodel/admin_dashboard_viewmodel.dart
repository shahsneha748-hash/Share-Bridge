import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// One activity feed entry
class ActivityItem {
  final IconData icon;
  final String text;
  final DateTime time;

  ActivityItem({required this.icon, required this.text, required this.time});
}

/// One top donor entry
class TopDonor {
  final String name;
  final int items;

  TopDonor({required this.name, required this.items});
}

/// One flagged report entry
class FlaggedItem {
  final String id;
  final String reason;
  final String details;
  final String reportType;
  final DateTime createdAt;

  FlaggedItem({
    required this.id,
    required this.reason,
    required this.details,
    required this.reportType,
    required this.createdAt,
  });
}

class AdminDashboardViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  // Overview counts
  int totalDonations = 0;
  int donationsToday = 0;
  int activeUsers = 0;
  int newUsersToday = 0;
  int pendingReports = 0;
  int availableDonations = 0;

  // Category distribution: label -> percent (0-100)
  Map<String, int> categoryPercents = {};

  // Top donors
  List<TopDonor> topDonors = [];

  // Flagged (pending reports)
  List<FlaggedItem> flagged = [];

  // Recent activity
  List<ActivityItem> activity = [];

  Future<void> fetchDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      // ── Donations ──
      final donationsSnap =
      await _firestore.collection('donations').get();
      totalDonations = donationsSnap.docs.length;
      donationsToday = 0;
      availableDonations = 0;

      final Map<String, int> categoryCounts = {};
      final Map<String, int> donorCounts = {};
      final List<ActivityItem> feed = [];

      for (final doc in donationsSnap.docs) {
        final data = doc.data();

        if (data['isDonated'] != true) availableDonations++;

        final created = (data['createdAt'] as Timestamp?)?.toDate();
        if (created != null && created.isAfter(todayStart)) {
          donationsToday++;
        }

        // Category counts
        final cat = (data['category'] ?? 'others')
            .toString()
            .toLowerCase();
        categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;

        // Donor counts (skip unknown/empty)
        final donorName = (data['donorName'] ?? '').toString();
        if (donorName.isNotEmpty && donorName != 'Unknown') {
          donorCounts[donorName] = (donorCounts[donorName] ?? 0) + 1;
        }

        // Activity: recent donations
        if (created != null) {
          final title = data['title'] ?? data['itemName'] ?? 'an item';
          feed.add(ActivityItem(
            icon: Icons.card_giftcard,
            text:
            'New donation "$title"${donorName.isNotEmpty && donorName != 'Unknown' ? ' by $donorName' : ''}',
            time: created,
          ));
        }
      }

      // Category percentages
      categoryPercents = {};
      if (totalDonations > 0) {
        categoryCounts.forEach((cat, count) {
          final label =
              cat[0].toUpperCase() + cat.substring(1); // Food, Clothes...
          categoryPercents[label] =
              ((count / totalDonations) * 100).round();
        });
      }

      // Top donors (sorted, top 3)
      final donorList = donorCounts.entries
          .map((e) => TopDonor(name: e.key, items: e.value))
          .toList()
        ..sort((a, b) => b.items.compareTo(a.items));
      topDonors = donorList.take(3).toList();

      // ── Users ──
      final usersSnap = await _firestore.collection('users').get();
      activeUsers = usersSnap.docs
          .where((d) => d.data()['status'] != 'banned')
          .length;
      newUsersToday = 0;
      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final created = (data['createdAt'] as Timestamp?)?.toDate();
        if (created != null && created.isAfter(todayStart)) {
          newUsersToday++;
        }
        if (created != null) {
          final name = data['fullName'] ?? 'A user';
          feed.add(ActivityItem(
            icon: Icons.person_add_alt,
            text: 'New user registered · $name',
            time: created,
          ));
        }
      }

      // ── Reports ──
      final reportsSnap = await _firestore.collection('reports').get();
      pendingReports = 0;
      flagged = [];

      for (final doc in reportsSnap.docs) {
        final data = doc.data();
        final status =
        (data['status'] ?? 'pending').toString().toLowerCase();
        final created =
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        if (status == 'pending') {
          pendingReports++;
          flagged.add(FlaggedItem(
            id: doc.id,
            reason: data['reason'] ?? 'Reported',
            details: data['details'] ?? '',
            reportType: data['reportType'] ?? '',
            createdAt: created,
          ));
        }

        feed.add(ActivityItem(
          icon: Icons.flag_outlined,
          text: 'Report submitted · ${data['reason'] ?? ''}',
          time: created,
        ));
      }

      // Flagged: newest first, keep top 2
      flagged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (flagged.length > 2) flagged = flagged.take(2).toList();

      // Activity: newest first, keep top 6
      feed.sort((a, b) => b.time.compareTo(a.time));
      activity = feed.take(6).toList();
    } catch (e) {
      debugPrint('Dashboard fetch error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  String relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} d ago';
  }
}