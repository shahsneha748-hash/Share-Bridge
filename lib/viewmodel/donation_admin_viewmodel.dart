import 'package:flutter/material.dart';
import '../model/donation_admin_model.dart';
import '../repo/donation_admin_repo.dart';
import '../repo/donation_admin_repo_impl.dart';

class DonationAdminViewModel extends ChangeNotifier {
  final DonationAdminRepo _repo = DonationAdminRepoImpl();

  bool _isLoading = true;
  String _searchQuery = '';
  DonationCategory? _filterCategory;
  DonationStatus? _filterStatus;
  List<AdminDonation> _allDonations = [];

  bool get isLoading => _isLoading;
  DonationCategory? get filterCategory => _filterCategory;
  DonationStatus? get filterStatus => _filterStatus;

  int get totalDonations => _allDonations.length;
  int get availableCount =>
      _allDonations.where((d) => d.status == DonationStatus.available).length;
  int get takenCount =>
      _allDonations.where((d) => d.status == DonationStatus.taken).length;
  int get foodCount =>
      _allDonations.where((d) => d.category == DonationCategory.food).length;

  List<AdminDonation> get filteredDonations {
    return _allDonations.where((donation) {
      final matchesSearch = donation.title
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _filterCategory == null || donation.category == _filterCategory;
      final matchesStatus =
          _filterStatus == null || donation.status == _filterStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Future<void> loadDonations() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _repo.fetchDonations();
      _allDonations = data.map(AdminDonation.fromMap).toList();
    } catch (e) {
      debugPrint('Error loading donations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(DonationCategory? category) {
    _filterCategory = category;
    _filterStatus = null; // reset status when category selected
    notifyListeners();
  }

  void setStatusFilter(DonationStatus? status) {
    _filterStatus = status;
    _filterCategory = null; // reset category when status selected
    notifyListeners();
  }

  Future<void> removePost(String donationId) async {
    try {
      await _repo.removeDonation(donationId);
      _allDonations.removeWhere((d) => d.id == donationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing donation: $e');
    }
  }
}