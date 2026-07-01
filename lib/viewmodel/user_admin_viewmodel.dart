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

  bool get isLoading => _isLoading;
  UserRole? get filterRole => _filterRole;
  UserStatus? get filterStatus => _filterStatus;

  int get totalUsers  => _allUsers.length;
  int get activeUsers => _allUsers.where((u) => u.status == UserStatus.active).length;
  int get bannedUsers => _allUsers.where((u) => u.status == UserStatus.banned).length;
  int get donorCount  => _allUsers.where((u) => u.role == UserRole.donor).length;

  List<AppUser> get filteredUsers {
    return _allUsers.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole   = _filterRole   == null || user.role   == _filterRole;
      final matchesStatus = _filterStatus == null || user.status == _filterStatus;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  // ── LOAD FROM FIRESTORE ────────────────────────────────────────────────────

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('users').get();
      _allUsers = snapshot.docs.map(AppUser.fromFirestore).toList();
    } catch (e) {
      debugPrint('Error loading users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── SEARCH & FILTER ────────────────────────────────────────────────────────

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

  // ── BAN / UNBAN ────────────────────────────────────────────────────────────

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