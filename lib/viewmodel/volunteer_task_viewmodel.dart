import 'package:flutter/material.dart';

import '../model/volunteer_task_model.dart';
import '../repo/volunteer_task_repo.dart';

class VolunteerTaskViewModel extends ChangeNotifier {
  final VolunteerTaskRepo _repo;

  VolunteerTaskViewModel(this._repo);

  Stream<List<VolunteerTaskModel>> get availableTasks =>
      _repo.getAvailableTasks();

  Stream<List<VolunteerTaskModel>> myTasks(String volunteerId) =>
      _repo.getMyTasks(volunteerId);

  Future<void> acceptTask({
    required String taskId,
    required String volunteerId,
  }) async {
    await _repo.acceptTask(
      taskId: taskId,
      volunteerId: volunteerId,
    );
  }

  Future<void> completeTask(String taskId) async {
    await _repo.completeTask(taskId);
  }
}