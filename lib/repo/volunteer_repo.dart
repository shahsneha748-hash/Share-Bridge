import '../model/volunteer_model.dart';
import '../model/volunteer_task_model.dart';

abstract class VolunteerRepo {
  Future<void> submitVolunteer(VolunteerModel model);
  Future<String> getStatus(String userId);

  Stream<String> getStatusStream(String userId);

  Stream<List<VolunteerModel>> watchAvailableApprovedVolunteers();

  Future<void> setAcceptingTasks(String userId, bool value);

  Stream<VolunteerModel> watchProfile(String userId);

}