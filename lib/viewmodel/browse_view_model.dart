import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sharebridge/model/browse_model.dart';
import 'package:sharebridge/repo/browse_repo.dart';
import 'package:sharebridge/repo/block_repo.dart';


class BrowseViewModel extends ChangeNotifier {
  final BrowseRepo _repo;
  final BlockRepo _blockRepo;
  BrowseModel _model = BrowseModel(allItems: []);
  StreamSubscription? _subscription;
  List<String> _blockedUserIds = [];


  bool _isLoading = true;
  bool get isLoading => _isLoading;


  double? _userLat;
  double? _userLng;


  // Firestore-backed favorites
  final Set<String> _favoriteIds = {};
  Set<String> get favoriteIds => _favoriteIds;


  BrowseViewModel(this._repo, this._blockRepo, {String? initialCategory}) {
    _listenToBrowseData();
    _loadUserLocation();
    _loadBlockedUsers();


    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) listenToFavorites(uid);


    if (initialCategory != null) {
      _selectedCategory = initialCategory;
    }
  }


  // Blocked users
  Future<void> _loadBlockedUsers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _blockedUserIds = await _blockRepo.getBlockedUserIds(uid);
    notifyListeners();
  }


  Future<void> refreshBlockedUsers() => _loadBlockedUsers();


  // Browse data
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


  //  Location
  String? _locationError;
  String? get locationError => _locationError;


  bool get hasUserLocation => _userLat != null && _userLng != null;


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


      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        _userLat = lastKnown.latitude;
        _userLng = lastKnown.longitude;
        notifyListeners();
      }


      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      _userLat = position.latitude;
      _userLng = position.longitude;
      notifyListeners();
      return true;
    } on TimeoutException {
      debugPrint('Browse location: GPS timed out, kept last-known.');
      return hasUserLocation;
    } catch (e) {
      debugPrint('Browse location error: $e');
      return false;
    }
  }


  Future<bool> ensureLocationForNearest() async {
    if (hasUserLocation) return true;
    return _loadUserLocation();
  }


  double? _distanceKmTo(Map<String, dynamic> item) {
    if (_userLat == null || _userLng == null) return null;
    final itemLat = (item['mapLat'] as num?)?.toDouble();
    final itemLng = (item['mapLng'] as num?)?.toDouble();
    if (itemLat == null || itemLng == null) return null;


    final meters =
    Geolocator.distanceBetween(_userLat!, _userLng!, itemLat, itemLng);
    return meters / 1000;
  }


  // Filters
  String _selectedCategory = 'All';
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


  //  Favorites (Firestore-backed)
  void listenToFavorites(String uid) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("saved_items")
        .snapshots()
        .listen((snapshot) {
      _favoriteIds
        ..clear()
        ..addAll(snapshot.docs.map((doc) => doc.id));
      notifyListeners();
    });
  }


  bool isFavorite(String id) => _favoriteIds.contains(id);


  Future<void> toggleFavorite(Map<String, dynamic> item) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final id = item["id"] ?? item["title"];


    if (!_favoriteIds.contains(id)) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("saved_items")
          .doc(id)
          .set({
        "id": id,
        "title": item["title"] ?? "",
        "image": item["image"] ?? "",
        "category": item["category"] ?? "Others",
        "miles": item["miles"] ?? "",
        "addedTime": item["addedTime"] ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("saved_items")
          .doc(id)
          .delete();
    }
  }


  // Filtering items
  double? _maxKmFor(String distanceLabel) {
    switch (distanceLabel) {
      case '1 km':
        return 1.0;
      case '5 km':
        return 5.0;
      default:
        return null;
    }
  }


  bool _isToday(DateTime? d) {
    if (d == null) return false;
    final today = DateTime.now();
    return d.year == today.year && d.month == today.month && d.day == today.day;
  }


  List<Map<String, dynamic>> get filteredItems {
    var list = List<Map<String, dynamic>>.from(_model.allItems)
        .where((e) => (e['status']?.toString() ?? 'available') == 'available')
        .where((e) => !_blockedUserIds.contains(e['donorId']))
        .toList();


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


    final maxKm = _maxKmFor(_distanceFilter);
    if (maxKm != null) {
      list = list.where((i) {
        final d = _distanceKmTo(i);
        if (d == null) return false;
        return d <= maxKm;
      }).toList();
    }


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
      list = list.where((i) => _isToday(i['createdAt'] as DateTime?)).toList();
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
        .where((e) => !_blockedUserIds.contains(e['donorId']))
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
      list = list.where((i) => _isToday(i['createdAt'] as DateTime?)).toList();
    }


    return list.length;
  }


  Future<void> refresh() async {
    await _loadBlockedUsers();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
  }


  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}