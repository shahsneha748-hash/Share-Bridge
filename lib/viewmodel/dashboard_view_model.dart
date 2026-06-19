import 'package:flutter/material.dart';
import 'package:sharebridge/model/dashboard_model.dart';
import 'package:sharebridge/repo/dashboard_repo.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepo _repo;
  late DashboardModel _model;

  DashboardViewModel(this._repo) {
    _load();
  }

  void _load() {
    _model = _repo.fetchDashboardData();
  }

  List<Map<String, dynamic>> get featuredItems {
    final sorted = List<Map<String, dynamic>>.from(_model.availableItems);
    sorted.sort((a, b) =>
        _parseDistance(a['distance']).compareTo(_parseDistance(b['distance'])));
    return sorted.take(4).toList();
  }

  int    get communityItemsShared => _model.communityItemsShared;
  double get communityProgress    => _model.communityProgress;
  int    get communityWeeklyGoal  => _model.communityWeeklyGoal;

  double _parseDistance(dynamic d) {
    if (d == null) return 999;
    final s = d.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(s) ?? 999;
  }

  void refresh() {
    _load();
    notifyListeners();
  }
}