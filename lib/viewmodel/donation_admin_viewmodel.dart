import 'package:flutter/material.dart';
import '../model/donation_admin_model.dart';

class DonationAdminViewModel extends ChangeNotifier {
  bool _isLoading = true;
  String _searchQuery = '';
  DonationCategory? _filterCategory;
  DonationStatus? _filterStatus;
  List<AdminDonation> _allDonations = [];

  bool get isLoading => _isLoading;
  DonationCategory? get filterCategory => _filterCategory;
  DonationStatus? get filterStatus => _filterStatus;

  int get totalDonations =>
      _allDonations.length;
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
          _filterCategory == null ||
              donation.category == _filterCategory;
      final matchesStatus =
          _filterStatus == null ||
              donation.status == _filterStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Future<void> loadDonations() async {
    _isLoading = true;
    notifyListeners();

    // Replace with Firestore later:
    // final snapshot = await FirebaseFirestore.instance
    //     .collection('donations').get();
    // _allDonations = snapshot.docs
    //     .map((d) => AdminDonation.fromMap(d.data())).toList();
    await Future.delayed(const Duration(milliseconds: 600));

    _allDonations = [
      AdminDonation(
        id: '1',
        title: 'Grocery Essentials Bundle',
        donorName: 'Sita Poudel',
        donorInitials: 'SP',
        category: DonationCategory.food,
        status: DonationStatus.available,
        location: 'Kathmandu',
        postedTime: '2 hrs ago',
      ),
      AdminDonation(
        id: '2',
        title: 'Cooked Meal',
        donorName: 'Mohan Rai',
        donorInitials: 'MR',
        category: DonationCategory.food,
        status: DonationStatus.available,
        location: 'Lalitpur',
        postedTime: '3 hrs ago',
      ),
      AdminDonation(
        id: '3',
        title: 'Winter Clothes Bundle',
        donorName: 'Bina KC',
        donorInitials: 'BK',
        category: DonationCategory.clothes,
        status: DonationStatus.taken,
        location: 'Bhaktapur',
        postedTime: '1 day ago',
      ),
      AdminDonation(
        id: '4',
        title: 'Warm Cardigan',
        donorName: 'Ram Thapa',
        donorInitials: 'RT',
        category: DonationCategory.clothes,
        status: DonationStatus.available,
        location: 'Kathmandu',
        postedTime: '5 hrs ago',
      ),
      AdminDonation(
        id: '5',
        title: 'Books for Students',
        donorName: 'Sita Sharma',
        donorInitials: 'SS',
        category: DonationCategory.stationery,
        status: DonationStatus.available,
        location: 'Lalitpur',
        postedTime: '2 days ago',
      ),
      AdminDonation(
        id: '6',
        title: 'Office Stationery Set',
        donorName: 'Bikash Thapa',
        donorInitials: 'BT',
        category: DonationCategory.stationery,
        status: DonationStatus.taken,
        location: 'Kathmandu',
        postedTime: '3 days ago',
      ),
      AdminDonation(
        id: '7',
        title: 'Household Items',
        donorName: 'Anita N',
        donorInitials: 'AN',
        category: DonationCategory.others,
        status: DonationStatus.available,
        location: 'Bhaktapur',
        postedTime: '6 hrs ago',
      ),
      AdminDonation(
        id: '8',
        title: 'Rice and Lentils',
        donorName: 'Rahul K',
        donorInitials: 'RK',
        category: DonationCategory.food,
        status: DonationStatus.taken,
        location: 'Kathmandu',
        postedTime: '4 days ago',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(DonationCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setStatusFilter(DonationStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void removePost(String donationId) {
    _allDonations.removeWhere((d) => d.id == donationId);
    notifyListeners();
    // Replace with Firestore later:
    // await FirebaseFirestore.instance
    //     .collection('donations').doc(donationId).delete();
  }
}