import '../model/volunteer_task_model.dart';

abstract class VolunteerTaskRepo {
  /// Get all available tasks
  Stream<List<VolunteerTaskModel>> getAvailableTasks();

  /// Get tasks accepted by a specific volunteer
  Stream<List<VolunteerTaskModel>> getMyTasks(String volunteerId);

  /// Accept a task
  Future<void> acceptTask({
    required String taskId,
    required String volunteerId,
  });

  /// Complete a task
  Future<void> completeTask(String taskId);
}