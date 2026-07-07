import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sharebridge/model/browse_model.dart';
import 'package:sharebridge/repo/browse_repo.dart';
import 'package:sharebridge/view/item_data.dart';

class BrowseViewModel extends ChangeNotifier {
  final BrowseRepo _repo;
  BrowseModel _model = BrowseModel(allItems: []);
  StreamSubscription? _subscription;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // ── User's current location, used for distance filter + Nearest sort ──
  double? _userLat;
  double? _userLng;

  BrowseViewModel(this._repo, {String? initialCategory}) {
    _listenToBrowseData();
    _loadUserLocation();
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

  // Tracks *why* we don't have a location yet, so the UI can show the
  // right message instead of silently doing nothing.
  String? _locationError; // null | 'service_disabled' | 'permission_denied'
  String? get locationError => _locationError;

  bool get hasUserLocation => _userLat != null && _userLng != null;

  // Fetches the user's current position once, so distance filter/sort
  // has something to compare item coordinates against. Returns true if
  // a location was obtained.
  Future<bool> _loadUserLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'service_disabled';
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _locationError = 'permission_denied';
        notifyListeners();
        return false;
      }

      _locationError = null;

      // Show an immediate estimate from the last cached fix if available.
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _userLat = lastKnown.latitude;
        _userLng = lastKnown.longitude;
        notifyListeners();
      }

      // Then refine with a fresh fix (bounded so it can't hang forever).
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      _userLat = position.latitude;
      _userLng = position.longitude;
      notifyListeners();
      return true;
    } on TimeoutException {
      debugPrint('Browse location: fresh GPS fix timed out, kept last-known.');
      return hasUserLocation; // last-known still counts as a success
    } catch (e) {
      debugPrint('Browse location error: $e');
      return false;
    }
  }

  // Public entry point for the "Nearest" tap — actively requests
  // permission/location right now instead of relying only on the silent
  // background fetch from app start. Returns true if location is ready.
  Future<bool> ensureLocationForNearest() async {
    if (hasUserLocation) return true;
    return _loadUserLocation();
  }

  // Distance in km from the user to an item, or null if either the
  // user's location or the item's coordinates aren't available.
  double? _distanceKmTo(Map<String, dynamic> item) {
    if (_userLat == null || _userLng == null) return null;
    final itemLat = (item['mapLat'] as num?)?.toDouble();
    final itemLng = (item['mapLng'] as num?)?.toDouble();
    if (itemLat == null || itemLng == null) return null;

    final meters =
    Geolocator.distanceBetween(_userLat!, _userLng!, itemLat, itemLng);
    return meters / 1000;
  }

  String _selectedCategory = 'All';
  // 'Newest' | 'Nearest' | 'Today'
  String _sortBy = 'Newest';
  String _distanceFilter = 'Anywhere';
  String _searchQuery = '';

  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  String get distanceFilter => _distanceFilter;
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

  void setSearchQuery(String query) {
    _searchQuery = query;
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
    required String sort,
  }) {
    _selectedCategory = category;
    _distanceFilter = distance;
    _sortBy = sort;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _distanceFilter = 'Anywhere';
    _sortBy = 'Newest';
    notifyListeners();
  }

  double? _maxKmFor(String distanceLabel) {
    switch (distanceLabel) {
      case '1 km':
        return 1.0;
      case '5 km':
        return 5.0;
      default:
        return null; // Anywhere — no cap
    }
  }

  bool _isToday(DateTime? d) {
    if (d == null) return false;
    final today = DateTime.now();
    return d.year == today.year && d.month == today.month && d.day == today.day;
  }

  List<Map<String, dynamic>> get filteredItems {
    // Browse only ever shows available items, so no separate
    // "available only" toggle is needed — this is always applied.
    var list = List<Map<String, dynamic>>.from(_model.allItems)
        .where((e) => (e['status']?.toString() ?? 'available') == 'available')
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

    // ── Distance filter (1 km / 5 km / Anywhere) ──────────────────
    final maxKm = _maxKmFor(_distanceFilter);
    if (maxKm != null) {
      list = list.where((i) {
        final d = _distanceKmTo(i);
        if (d == null) return false;
        return d <= maxKm;
      }).toList();
    }

    // ── Sort (Newest / Nearest / Today) ───────────────────────────
    if (_sortBy == 'Nearest') {
      list.sort((a, b) {
        final aD = _distanceKmTo(a);
        final bD = _distanceKmTo(b);
        if (aD == null && bD == null) return 0;
        if (aD == null) return 1;
        if (bD == null) return -1;
        return aD.compareTo(bD);
      });
    } else if (_sortBy == 'Today') {
      list = list
          .where((i) => _isToday(i['createdAt'] as DateTime?))
          .toList();
      list.sort((a, b) {
        final aDate = a['createdAt'] as DateTime?;
        final bDate = b['createdAt'] as DateTime?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    } else {
      // Default: Newest
      list.sort((a, b) {
        final aDate = a['createdAt'] as DateTime?;
        final bDate = b['createdAt'] as DateTime?;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    }

    return list;
  }

  int previewCount({
    required String category,
    required String distance,
    required String sort,
  }) {
    var list = List<Map<String, dynamic>>.from(_model.allItems)
        .where((e) => (e['status']?.toString() ?? 'available') == 'available')
        .toList();

    if (category != 'All') {
      list = list.where((i) => i['category'] == category).toList();
    }

    final maxKm = _maxKmFor(distance);
    if (maxKm != null) {
      list = list.where((i) {
        final d = _distanceKmTo(i);
        if (d == null) return false;
        return d <= maxKm;
      }).toList();
    }

    if (sort == 'Today') {
      list = list
          .where((i) => _isToday(i['createdAt'] as DateTime?))
          .toList();
    }

    return list.length;
  }

  Future<void> refresh() async {
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}