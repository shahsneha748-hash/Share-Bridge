import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/admin_model.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  DashboardStats? _stats;
  List<FlaggedPost> _flaggedPosts = [];
  List<ActivityItem> _activityFeed = [];
  List<TopDonor> _topDonors = [];
  List<CategoryStat> _categories = [];
  bool _isLoading = true;

  DashboardStats? get stats => _stats;
  List<FlaggedPost> get flaggedPosts => _flaggedPosts;
  List<ActivityItem> get activityFeed => _activityFeed;
  List<TopDonor> get topDonors => _topDonors;
  List<CategoryStat> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Real data from Firestore
      final usersSnapshot = await _db.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;

      final reportsSnapshot = await _db
          .collection('reports')
          .where('status', isEqualTo: 'pending')
          .get();
      final flaggedCount = reportsSnapshot.docs.length;

      _stats = DashboardStats(
        totalDonations: 0, // ⏳ teammates' data
        activeUsers: totalUsers,
        pendingRequests: 0, // ⏳ teammates' data
        flaggedPosts: flaggedCount,
      );

      // Flagged posts from reports collection
      _flaggedPosts = reportsSnapshot.docs.map((doc) {
        final data = doc.data();
        final name = data['reportedName'] as String? ?? 'Unknown';
        return FlaggedPost(
          id: doc.id,
          initials: name.isNotEmpty ? name[0].toUpperCase() : '?',
          title: name,
          reason: data['reason'] as String? ?? '',
          postedBy: data['isAnonymous'] == true
              ? 'Anonymous'
              : data['reporterName'] as String? ?? 'Unknown',
          reportCount: 1,
          timeAgo: _timeAgo(data['createdAt']),
        );
      }).toList();

    } catch (e) {
      debugPrint('Error loading dashboard: $e');

      // Fallback dummy data if Firestore fails
      _stats = DashboardStats(
        totalDonations: 0,
        activeUsers: 0,
        pendingRequests: 0,
        flaggedPosts: 0,
      );
    }

    // Keep dummy data for things we can't get yet
    _activityFeed = [
      ActivityItem(
        description: 'New food donation posted by Sita Poudel',
        timeAgo: '2 min ago',
        type: ActivityType.donation,
      ),
      ActivityItem(
        description: 'New user registered · Ram Thapa',
        timeAgo: '11 min ago',
        type: ActivityType.newUser,
      ),
      ActivityItem(
        description: 'Request pending for 2hrs · Blankets post',
        timeAgo: '34 min ago',
        type: ActivityType.pending,
      ),
      ActivityItem(
        description: 'Post flagged for misuse · reported ×2',
        timeAgo: '1 hr ago',
        type: ActivityType.flagged,
      ),
      ActivityItem(
        description: 'Donation confirmed received · Books lot',
        timeAgo: '2 hr ago',
        type: ActivityType.confirmed,
      ),
    ];

    _topDonors = [
      TopDonor(initials: 'SP', name: 'Sita Poudel', itemCount: 24, rank: 1),
      TopDonor(initials: 'MR', name: 'Mohan Rai',   itemCount: 19, rank: 2),
      TopDonor(initials: 'BK', name: 'Bina KC',     itemCount: 15, rank: 3),
    ];

    _categories = [
      CategoryStat(label: 'Food',    percentage: 0.72),
      CategoryStat(label: 'Clothes', percentage: 0.18),
      CategoryStat(label: 'Books',   percentage: 0.10),
    ];

    _isLoading = false;
    notifyListeners();
  }

  String _timeAgo(dynamic createdAt) {
    if (createdAt == null) return '';
    DateTime dt;
    if (createdAt is Timestamp) {
      dt = createdAt.toDate();
    } else {
      return '';
    }
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day ago';
  }

  void removePost(String postId) {
    _flaggedPosts.removeWhere((post) => post.id == postId);
    if (_stats != null) {
      _stats = DashboardStats(
        totalDonations: _stats!.totalDonations,
        activeUsers: _stats!.activeUsers,
        pendingRequests: _stats!.pendingRequests,
        flaggedPosts: _stats!.flaggedPosts - 1,
      );
    }
    notifyListeners();
  }

  void keepPost(String postId) {
    _flaggedPosts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }
}