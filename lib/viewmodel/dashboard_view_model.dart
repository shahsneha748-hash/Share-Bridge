import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sharebridge/model/dashboard_model.dart';
import 'package:sharebridge/repo/dashboard_repo.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepo _repo;

  DashboardModel _model = DashboardModel(
    donations: [],
  );

  StreamSubscription? _subscription;

  DashboardViewModel(this._repo) {
    _listenToDonations();
  }

  void _listenToDonations() {
    _subscription = _repo.getDashboardData().listen((data) {
      _model = data;
      notifyListeners();
    });
  }

  List<Map<String, dynamic>> get featuredItems {
    return _model.donations.take(4).toList();
  }

  List<Map<String, dynamic>> get donations => _model.donations;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}