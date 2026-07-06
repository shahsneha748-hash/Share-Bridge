import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sharebridge/model/browse_model.dart';
import 'package:sharebridge/repo/browse_repo.dart';
import 'package:sharebridge/view/item_data.dart';

class BrowseViewModel extends ChangeNotifier {
  final BrowseRepo _repo;
  BrowseModel _model = BrowseModel(allItems: []);
  StreamSubscription? _subscription;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  BrowseViewModel(this._repo, {String? initialCategory}) {
    _listenToBrowseData();
    if (initialCategory != null) {
      _selectedCategory = initialCategory;
    }
  }

  void _listenToBrowseData() {
    _subscription = _repo.getBrowseData().listen(
          (data) {
        _model = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Browse stream error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  String _selectedCategory = 'All';
  String _sortBy = 'Newest';
  String _distanceFilter = 'Anywhere';
  bool _availableOnly = false;
  bool _todayOnly = false;
  String _searchQuery = '';

  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  String get distanceFilter => _distanceFilter;
  bool get availableOnly => _availableOnly;
  bool get todayOnly => _todayOnly;
  String get searchQuery => _searchQuery;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateInitialCategory(String? category) {
    if (category != null && category != _selectedCategory) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void toggleSortNearest() {
    _sortBy = _sortBy == 'Nearest' ? 'Newest' : 'Nearest';
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleAvailableOnly() {
    _availableOnly = !_availableOnly;
    notifyListeners();
  }

  void toggleTodayOnly() {
    _todayOnly = !_todayOnly;
    notifyListeners();
  }

  void toggleFavorite(String title) {
    Favorites.toggle(title);
    notifyListeners();
  }

  bool isFavorite(String title) => Favorites.isFavorite(title);

  void applyFilters({
    required String category,
    required String distance,
    required bool available,
    required String sort,
  }) {
    _selectedCategory = category;
    _distanceFilter = distance;
    _availableOnly = available;
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _distanceFilter = 'Anywhere';
    _availableOnly = false;
    _sortBy = 'Newest';
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredItems {
    final now = DateTime.now();

    var list = List<Map<String, dynamic>>.from(_model.allItems)
    // ── 12-hour claimed-item grace period ───────────────────────
    // Show item if:
    // 1. It is still available
    // 2. OR it was claimed less than 12 hours ago (still visible)
    // Items claimed more than 12 hours ago are hidden from browse
        .where((e) {
      final status = e['status']?.toString() ?? 'available';
      if (status == 'available') return true;
      if (status == 'claimed') {
        final acceptedAt = e['acceptedAt'] as DateTime?;
        if (acceptedAt == null) return false;
        return now.difference(acceptedAt).inHours < 12;
      }
      return false;
    })
        .toList();

    // ── Category filter ──────────────────────────────────────────
    if (_selectedCategory != 'All') {
      list = list
          .where((i) => i['category'] == _selectedCategory)
          .toList();
    }

    // ── Search filter ────────────────────────────────────────────
    if (_searchQuery.isNotEmpty) {
      list = list.where((i) {
        return i['title']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // ── Available only filter ────────────────────────────────────
    if (_availableOnly) {
      list = list.where((i) => i['status'] == 'available').toList();
    }

    // ── Today only filter ────────────────────────────────────────
    if (_todayOnly) {
      final today = DateTime.now();
      list = list.where((i) {
        final createdAt = i['createdAt'] as DateTime?;
        if (createdAt == null) return false;
        return createdAt.year == today.year &&
            createdAt.month == today.month &&
            createdAt.day == today.day;
      }).toList();
    }

    // ── Sort ─────────────────────────────────────────────────────
    if (_sortBy == 'Newest') {
      list.sort((a, b) {
        final aDate = a['createdAt'] as DateTime?;
        final bDate = b['createdAt'] as DateTime?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    } else if (_sortBy == 'Available') {
      list.sort((a, b) {
        final aAvail = a['status'] == 'available';
        final bAvail = b['status'] == 'available';
        if (aAvail == bAvail) return 0;
        return aAvail ? -1 : 1;
      });
    }

    return list;
  }

  int previewCount({
    required String category,
    required String distance,
    required bool available,
  }) {
    var list = List<Map<String, dynamic>>.from(_model.allItems);
    if (category != 'All') {
      list = list.where((i) => i['category'] == category).toList();
    }
    if (available) {
      list = list.where((i) => i['status'] == 'available').toList();
    }
    return list.length;
  }

  double _parseDistance(dynamic d) {
    if (d == null) return 999;
    final s = d.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(s) ?? 999;
  }

  void refresh() {
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}