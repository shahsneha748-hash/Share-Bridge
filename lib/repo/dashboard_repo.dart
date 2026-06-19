import 'package:sharebridge/model/dashboard_model.dart';

abstract class DashboardRepo {
  DashboardModel fetchDashboardData();
}