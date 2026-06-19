import 'package:flutter/material.dart';

import '../model/volunteer_model.dart';
import '../repo/volunteer_repo.dart';

class VolunteerViewModel extends ChangeNotifier {

  final VolunteerRepo _repo;

  VolunteerViewModel({
    required VolunteerRepo repo,
  }) : _repo = repo;

  List<VolunteerTaskModel> availableTasks = [];

  List<VolunteerTaskModel> myTasks = [];

  bool loading = false;

  void loadAvailableTasks() {

    _repo.getAvailableTasks().listen((event) {

      availableTasks = event;

      notifyListeners();
    });
  }

  void loadMyTasks(String volunteerId) {

    _repo
        .getMyTasks(volunteerId)
        .listen((event) {

      myTasks = event;

      notifyListeners();
    });
  }

  Future<void> acceptTask({
    required String donationId,
    required String volunteerId,
  }) async {

    loading = true;
    notifyListeners();

    try {

      await _repo.acceptTask(
        donationId: donationId,
        volunteerId: volunteerId,
      );

    } finally {

      loading = false;
      notifyListeners();
    }
  }
}