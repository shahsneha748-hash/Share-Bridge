import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sharebridge/model/dashboard_model.dart';
import 'package:sharebridge/repo/dashboard_repo.dart';
import 'package:sharebridge/repo/block_repo.dart';

class DashboardViewModel extends ChangeNotifier {
  final DashboardRepo _repo;
  final BlockRepo _blockRepo;

  DashboardModel _model = DashboardModel(donations: [], id: '');
  List<String> _blockedUserIds = [];
  StreamSubscription? _subscription;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  DashboardViewModel(this._repo, this._blockRepo) {
    _loadBlockedUsers();
    _listenToDonations();
  }

  Future<void> _loadBlockedUsers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _blockedUserIds = await _blockRepo.getBlockedUserIds(uid);
    notifyListeners();
  }

  Future<void> refreshBlockedUsers() => _loadBlockedUsers();

  void _listenToDonations() {
    _subscription = _repo.getDashboardData().listen((data) {
      _model = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Dashboard stream error: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  List<Map<String, dynamic>> get featuredItems {
    return _model.donations
        .where((e) =>
    e['status'] == 'available' &&
        !_blockedUserIds.contains(e['donorId']))
        .take(5)
        .toList();
  }

  List<Map<String, dynamic>> get donations {
    return _model.donations
        .where((e) => !_blockedUserIds.contains(e['donorId']))
        .toList();
  }

  Future<void> refresh() async {
    await _loadBlockedUsers();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}