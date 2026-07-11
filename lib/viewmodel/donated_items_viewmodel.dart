import 'dart:async';
import 'package:flutter/material.dart';
import '../model/volunteer_request_model.dart';
import '../repo/donated_item_repo.dart';

class DonatedItemsViewModel extends ChangeNotifier {
  final DonatedItemsRepo repo;
  DonatedItemsViewModel({required this.repo});

  List<VolunteerRequestModel> items = [];
  bool loading = false;
  StreamSubscription? _sub;
  String? _currentDonorId;

  void listenFor(String donorId) {
    if (_currentDonorId == donorId) return;
    _currentDonorId = donorId;
    _sub?.cancel();
    loading = true;
    notifyListeners();
    _sub = repo.getDonatedItems(donorId).listen((data) {
      items = data;
      loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}