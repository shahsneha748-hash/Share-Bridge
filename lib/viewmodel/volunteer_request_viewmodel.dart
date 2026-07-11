import 'dart:async';
import 'package:flutter/material.dart';
import '../model/volunteer_request_model.dart';
import '../repo/volunteer_request_repo.dart';

class VolunteerRequestViewModel extends ChangeNotifier {
  final VolunteerRequestRepo repo;
  VolunteerRequestViewModel(this.repo);

  bool loading = false;
  List<VolunteerRequestModel> requests = [];
  StreamSubscription? _sub;

  Future<void> createRequest(VolunteerRequestModel request) async {
    loading = true;
    notifyListeners();
    await repo.createRequest(request);
    loading = false;
    notifyListeners();
  }

  void listenRequests({required String volunteerId}) {
    _sub?.cancel();
    _sub = repo.getVolunteerRequests().listen((data) {
      requests = data.where((r) => !r.rejectedBy.contains(volunteerId)).toList();
      notifyListeners();
    });
  }


  void stopListening() {
    _sub?.cancel();
    _sub = null;
  }

  Future<bool> acceptRequest(String id, String volunteerId) async {
    return await repo.acceptRequest(id, volunteerId);
  }

  Future<void> rejectRequest(String id, String volunteerId) async {
    await repo.rejectRequest(id, volunteerId);
  }

  Future<void> confirmDelivery(String id) async {
    await repo.confirmDelivery(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}