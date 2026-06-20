import 'package:flutter/material.dart';
import '../model/admin_model.dart';

class AdminDashboardViewModel extends ChangeNotifier {

  DashboardStats? _stats;
  List<FlaggedPost> _flaggedPosts = [];
  List<ActivityItem> _activityFeed = [];
  List<TopDonor> _topDonors = [];
  List<CategoryStat> _categories = [];
  bool _isLoading = true;

  // Getters — view reads these, cannot write directly
  DashboardStats? get stats => _stats;
  List<FlaggedPost> get flaggedPosts => _flaggedPosts;
  List<ActivityItem> get activityFeed => _activityFeed;
  List<TopDonor> get topDonors => _topDonors;
  List<CategoryStat> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    // Simulated delay — replace with Firestore calls later
    await Future.delayed(const Duration(milliseconds: 800));

    _stats = DashboardStats(
      totalDonations: 248,
      activeUsers: 1043,
      pendingRequests: 34,
      flaggedPosts: 5,
    );

    _flaggedPosts = [
      FlaggedPost(
        id: '1',
        initials: 'RK',
        title: 'Selling item as free donation',
        reason: 'Misuse',
        postedBy: 'Rahul K',
        reportCount: 2,
        timeAgo: '1hr ago',
      ),
      FlaggedPost(
        id: '2',
        initials: 'AN',
        title: 'Expired food listed as fresh',
        reason: 'Safety',
        postedBy: 'Anita N',
        reportCount: 4,
        timeAgo: '3hr ago',
      ),
    ];

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