class DashboardStats {
  final int totalDonations;
  final int activeUsers;
  final int pendingRequests;
  final int flaggedPosts;

  DashboardStats({
    required this.totalDonations,
    required this.activeUsers,
    required this.pendingRequests,
    required this.flaggedPosts,
  });
}

class FlaggedPost {
  final String id;
  final String initials;
  final String title;
  final String reason;
  final String postedBy;
  final int reportCount;
  final String timeAgo;

  FlaggedPost({
    required this.id,
    required this.initials,
    required this.title,
    required this.reason,
    required this.postedBy,
    required this.reportCount,
    required this.timeAgo,
  });
}

enum ActivityType { donation, newUser, pending, flagged, confirmed }

class ActivityItem {
  final String description;
  final String timeAgo;
  final ActivityType type;

  ActivityItem({
    required this.description,
    required this.timeAgo,
    required this.type,
  });
}

class TopDonor {
  final String initials;
  final String name;
  final int itemCount;
  final int rank;

  TopDonor({
    required this.initials,
    required this.name,
    required this.itemCount,
    required this.rank,
  });
}

class CategoryStat {
  final String label;
  final double percentage;

  CategoryStat({required this.label, required this.percentage});
}