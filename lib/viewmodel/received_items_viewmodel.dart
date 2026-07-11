import 'dart:async';
import 'package:flutter/material.dart';
import '../model/volunteer_request_model.dart';
import '../repo/received_item_repo.dart';

class ReceivedItemsViewModel extends ChangeNotifier {
  final ReceivedItemsRepo repo;
  ReceivedItemsViewModel({required this.repo});

  List<VolunteerRequestModel> items = [];
  bool loading = false;
  StreamSubscription? _sub;
  String? _currentReceiverId;

  void listenFor(String receiverId) {
    if (_currentReceiverId == receiverId) return;
    _currentReceiverId = receiverId;
    _sub?.cancel();
    loading = true;
    notifyListeners();
    _sub = repo.getReceivedItems(receiverId).listen((data) {
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