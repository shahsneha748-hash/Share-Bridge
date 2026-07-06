import 'package:flutter/material.dart';
import '../model/request_system_model.dart';
import '../repo/request_system_repo.dart';

enum RequestFilter { all, accepted, rejected }

class RequestSystemViewModel extends ChangeNotifier {
  final RequestSystemRepo repository;

  RequestSystemViewModel({required this.repository}) {
    _listenToRequests();
  }

  List<RequestSystemModel> _allRequests = [];
  RequestFilter _filter = RequestFilter.all;
  String _searchQuery = '';
  bool isLoading = true;
  String? errorMessage;

  RequestFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  List<RequestSystemModel> get filteredRequests {
    List<RequestSystemModel> result = _allRequests;

    if (_filter == RequestFilter.all) {
      result = result.where((r) => r.status == 'pending').toList();
    } else {
      result = result.where((r) => r.status == _filter.name).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((r) =>
      r.itemName.toLowerCase().contains(q) ||
          r.donorName.toLowerCase().contains(q) ||
          r.category.toLowerCase().contains(q) ||
          r.location.toLowerCase().contains(q)
      ).toList();
    }

    return result;
  }

  int get acceptedCount => _allRequests.where((r) => r.status == 'accepted').length;
  int get rejectedCount => _allRequests.where((r) => r.status == 'rejected').length;

  void _listenToRequests() {
    repository.getRequests().listen(
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
      await repository.updateStatus(requestId, status);
    } catch (e) {
      errorMessage = 'Failed to update status.';
      notifyListeners();
    }
  }
}