import 'package:flutter/material.dart';
import '../model/request_system_model.dart';
import '../repo/request_system_repo.dart';

enum RequestFilter { all, pending, accepted, rejected }

class DonationRequestViewModel extends ChangeNotifier {
  final DonationRequestRepository _repository;

  DonationRequestViewModel({required DonationRequestRepository repository})
      : _repository = repository {
    _listenToRequests();
  }

  List<DonationRequestModel> _allRequests = [];
  RequestFilter _filter = RequestFilter.all;
  String _searchQuery = '';
  bool isLoading = true;
  String? errorMessage;

  RequestFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  List<DonationRequestModel> get filteredRequests {
    List<DonationRequestModel> result = _allRequests;

    if (_filter != RequestFilter.all) {
      result = result.where((r) => r.status == _filter.name).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((r) =>
      r.itemName.toLowerCase().contains(q) ||
          r.category.toLowerCase().contains(q) ||
          r.location.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q)
      ).toList();
    }

    return result;
  }

  int get pendingCount  => _allRequests.where((r) => r.status == 'pending').length;
  int get acceptedCount => _allRequests.where((r) => r.status == 'accepted').length;
  int get rejectedCount => _allRequests.where((r) => r.status == 'rejected').length;

  void _listenToRequests() {
    _repository.getRequests().listen(
          (requests) {
        _allRequests = requests;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = 'Failed to load requests.';
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void setFilter(RequestFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> updateStatus(String requestId, String status) async {
    try {
      await _repository.updateStatus(requestId, status);
    } catch (e) {
      errorMessage = 'Failed to update status.';
      notifyListeners();
    }
  }
}