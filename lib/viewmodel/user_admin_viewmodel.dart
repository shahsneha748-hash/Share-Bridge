import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/user_admin_model.dart';

class UserAdminViewModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  bool _isLoading = true;
  String _searchQuery = '';
  UserRole? _filterRole;
  UserStatus? _filterStatus;
  List<AppUser> _allUsers = [];

  // User IDs computed for real activity

  Set<String> _donorIds = {};
  Set<String> _receiverIds = {};
  Set<String> _volunteerIds = {};

  bool get isLoading => _isLoading;

  UserRole? get filterRole => _filterRole;

  UserStatus? get filterStatus => _filterStatus;

  int get totalUsers => _allUsers.length;

  int get activeUsers =>
      _allUsers
          .where((u) => u.status == UserStatus.active)
          .length;

  int get bannedUsers =>
      _allUsers
          .where((u) => u.status == UserStatus.banned)
          .length;

  int get donorCount => _donorIds.length;

  // Helper

  bool _userHasRole(AppUser user, UserRole role) {
    switch (role) {
      case UserRole.donor:
        return _donorIds.contains(user.id);
      case UserRole.receiver:
        return _receiverIds.contains(user.id);
      case UserRole.volunteer:
        return _volunteerIds.contains(user.id);
      case UserRole.user:
        return true;
    }
  }

  List<AppUser> get filteredUsers {
    return _allUsers.where((user) {
      final matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole =
          _filterRole == null || _userHasRole(user, _filterRole!);
      final matchesStatus =
          _filterStatus == null || user.status == _filterStatus;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  // Load from firebase

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load all users

      final snapshot = await _db.collection('users').get();
      _allUsers = snapshot.docs.map(AppUser.fromFirestore).toList();

      // Compute donor IDs (anyone who posted a donation)
      final donationsSnap = await _db.collection('donations').get();
      _donorIds = donationsSnap.docs
          .map((d) => (d.data()['donorId'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toSet();

      // Compute receiver IDs (anyone in the requests collection)

      final requestsSnap = await _db.collection('requests').get();
      _receiverIds = requestsSnap.docs
          .map((d) =>
          (d.data()['requesterId'] ?? d.data()['userId'] ?? '')
              .toString())
          .where((id) => id.isNotEmpty)
          .toSet();

      // Compute volunteer IDs (anyone in the volunteers collection)
      final volunteersSnap = await _db.collection('volunteers').get();
      _volunteerIds = volunteersSnap.docs
          .map((d) => (d.data()['userId'] ?? d.id).toString())
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (e) {
      debugPrint('Error loading users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  //Search and filter

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setRoleFilter(UserRole? role) {
    _filterRole = role;
    notifyListeners();
  }

  void setStatusFilter(UserStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

// Ban & Unban

  Future<void> banUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).update({'isBanned': true});
      final index = _allUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _allUsers[index].status = UserStatus.banned;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error banning user: $e');
    }
  }

  Future<void> unbanUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).update({'isBanned': false});
      final index = _allUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _allUsers[index].status = UserStatus.active;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error unbanning user: $e');
    }
  }
}