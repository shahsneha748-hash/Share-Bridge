import 'package:sharebridge/model/dashboard_model.dart';
import 'package:sharebridge/repo/dashboard_repo.dart';
import 'package:sharebridge/view/item_data.dart';

class DashboardRepoImpl implements DashboardRepo {
  @override
  DashboardModel fetchDashboardData() {
    final available =
    sharedItems.where((i) => i['available'] == true).toList();

    return DashboardModel(
      availableItems: available,
      communityItemsShared: CommunityStats.itemsShared,
      communityProgress: CommunityStats.progress,
      communityWeeklyGoal: CommunityStats.weeklyGoal,
    );
  }
}