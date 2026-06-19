class DashboardModel {
  final List<Map<String, dynamic>> availableItems;
  final int communityItemsShared;
  final double communityProgress;
  final int communityWeeklyGoal;

  DashboardModel({
    required this.availableItems,
    required this.communityItemsShared,
    required this.communityProgress,
    required this.communityWeeklyGoal,
  });
}