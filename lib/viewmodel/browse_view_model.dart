import 'package:flutter/material.dart';
import 'package:sharebridge/model/browse_model.dart';
import 'package:sharebridge/repo/browse_repo.dart';
import 'package:sharebridge/view/item_data.dart';

class BrowseViewModel extends ChangeNotifier {
  final BrowseRepo _repo;
  late BrowseModel _model;

  BrowseViewModel(this._repo, {String? initialCategory}) {
    _load();
    if (initialCategory != null) {
      _selectedCategory = initialCategory;
    }
  }

  void _load() {
    _model = _repo.fetchBrowseData();
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
    var list = List<Map<String, dynamic>>.from(_model.allItems);

    if (_selectedCategory != 'All') {
      list = list.where((i) => i['category'] == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list.where((i) {
        return i['title']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_availableOnly) {
      list = list.where((i) => i['available'] == true).toList();
    }

    if (_todayOnly) {
      list = list.where((i) {
        final exp = i['expires']?.toString() ?? '';
        return exp.contains('h');
      }).toList();
    }

    if (_distanceFilter != 'Anywhere') {
      final maxKm = _distanceFilter == '1 km' ? 1.0 : 5.0;
      list = list.where((i) {
        final km = _parseDistance(i['distance']) * 1.6;
        return km <= maxKm;
      }).toList();
    }

    if (_sortBy == 'Nearest') {
      list.sort((a, b) => _parseDistance(a['distance'])
          .compareTo(_parseDistance(b['distance'])));
    } else if (_sortBy == 'Newest') {
      list.sort((a, b) => (a['expires'] ?? 'zz')
          .toString()
          .compareTo((b['expires'] ?? 'zz').toString()));
    } else if (_sortBy == 'Available') {
      list.sort((a, b) {
        if (a['available'] == b['available']) return 0;
        return a['available'] == true ? -1 : 1;
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
      list = list.where((i) => i['available'] == true).toList();
    }
    if (distance != 'Anywhere') {
      final maxKm = distance == '1 km' ? 1.0 : 5.0;
      list = list.where((i) {
        final km = _parseDistance(i['distance']) * 1.6;
        return km <= maxKm;
      }).toList();
    }
    return list.length;
  }

  double _parseDistance(dynamic d) {
    if (d == null) return 999;
    final s = d.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(s) ?? 999;
  }

  void refresh() {
    _load();
    notifyListeners();
  }
}