import '../model/volunteer_model.dart';

abstract class VolunteerRepo {

  Stream<List<VolunteerTaskModel>> getAvailableTasks();

  Stream<List<VolunteerTaskModel>> getMyTasks(
      String volunteerId);

  Future<void> acceptTask({
    required String donationId,
    required String volunteerId,
  });
}