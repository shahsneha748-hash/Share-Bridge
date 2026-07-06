import 'package:flutter/material.dart';
import '../model/admin_volunteer_model.dart';
import '../repo/admin_volunteer_repo.dart';
import '../repo/admin_volunteer_repo_impl.dart';

class AdminVolunteerViewModel extends ChangeNotifier {
  final AdminVolunteerRepo _repo = AdminVolunteerRepoImpl();

  List<AdminVolunteerModel> _volunteers = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';

  List<AdminVolunteerModel> get volunteers {
    if (_selectedFilter == 'All') return _volunteers;
    return _volunteers.where((v) => v.status == _selectedFilter).toList();
  }

  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  int get pendingCount =>
      _volunteers.where((v) => v.status == 'Pending').length;
  int get approvedCount =>
      _volunteers.where((v) => v.status == 'Approved').length;

  Future<void> loadVolunteers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _volunteers = await _repo.fetchVolunteers();
    } catch (e) {
      debugPrint('Error loading volunteers: $e');
      _volunteers = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> updateStatus(String volunteerId, String status) async {
    try {
      await _repo.updateVolunteerStatus(volunteerId, status);
      await loadVolunteers();
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }
}