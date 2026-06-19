import 'package:flutter/material.dart';
import '../model/user_admin_model.dart';

class UserAdminViewModel extends ChangeNotifier {
  bool _isLoading = true;
  String _searchQuery = '';
  UserRole? _filterRole;
  UserStatus? _filterStatus;
  List<AppUser> _allUsers = [];

  bool get isLoading => _isLoading;
  UserRole? get filterRole => _filterRole;
  UserStatus? get filterStatus => _filterStatus;

  int get totalUsers  => _allUsers.length;
  int get activeUsers =>
      _allUsers.where((u) => u.status == UserStatus.active).length;
  int get bannedUsers =>
      _allUsers.where((u) => u.status == UserStatus.banned).length;
  int get donorCount  =>
      _allUsers.where((u) => u.role == UserRole.donor).length;

  List<AppUser> get filteredUsers {
    return _allUsers.where((user) {
      final matchesSearch = user.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesRole =
          _filterRole == null || user.role == _filterRole;
      final matchesStatus =
          _filterStatus == null || user.status == _filterStatus;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    // Replace with Firestore later:
    // final snapshot = await FirebaseFirestore.instance
    //     .collection('users').get();
    // _allUsers = snapshot.docs
    //     .map((d) => AppUser.fromMap(d.data())).toList();
    await Future.delayed(const Duration(milliseconds: 600));

    _allUsers = [
      AppUser(
        id: '1',
        name: 'Sita Poudel',
        initials: 'SP',
        role: UserRole.donor,
        status: UserStatus.active,
        joinDate: 'Jan 2026',
        totalDonations: 24,
        totalRequests: 0,
        email: 'sita@email.com',
      ),
      AppUser(
        id: '2',
        name: 'Mohan Rai',
        initials: 'MR',
        role: UserRole.donor,
        status: UserStatus.active,
        joinDate: 'Feb 2026',
        totalDonations: 19,
        totalRequests: 2,
        email: 'mohan@email.com',
      ),
      AppUser(
        id: '3',
        name: 'Bina KC',
        initials: 'BK',
        role: UserRole.receiver,
        status: UserStatus.active,
        joinDate: 'Mar 2026',
        totalDonations: 0,
        totalRequests: 8,
        email: 'bina@email.com',
      ),
      AppUser(
        id: '4',
        name: 'Ram Thapa',
        initials: 'RT',
        role: UserRole.receiver,
        status: UserStatus.active,
        joinDate: 'Mar 2026',
        totalDonations: 0,
        totalRequests: 5,
        email: 'ram@email.com',
      ),
      AppUser(
        id: '5',
        name: 'Rahul K',
        initials: 'RK',
        role: UserRole.donor,
        status: UserStatus.banned,
        joinDate: 'Jan 2026',
        totalDonations: 3,
        totalRequests: 0,
        email: 'rahul@email.com',
      ),
      AppUser(
        id: '6',
        name: 'Anita N',
        initials: 'AN',
        role: UserRole.donor,
        status: UserStatus.banned,
        joinDate: 'Feb 2026',
        totalDonations: 5,
        totalRequests: 0,
        email: 'anita@email.com',
      ),
      AppUser(
        id: '7',
        name: 'Sita Sharma',
        initials: 'SS',
        role: UserRole.volunteer,
        status: UserStatus.active,
        joinDate: 'Dec 2025',
        totalDonations: 0,
        totalRequests: 0,
        email: 'sitasharma@email.com',
      ),
      AppUser(
        id: '8',
        name: 'Bikash Thapa',
        initials: 'BT',
        role: UserRole.donor,
        status: UserStatus.banned,
        joinDate: 'Nov 2025',
        totalDonations: 2,
        totalRequests: 0,
        email: 'bikash@email.com',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

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

  void banUser(String userId) {
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _allUsers[index].status = UserStatus.banned;
      notifyListeners();
    }
  }

  void unbanUser(String userId) {
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _allUsers[index].status = UserStatus.active;
      notifyListeners();
    }
  }
}