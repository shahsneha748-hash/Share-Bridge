import '../model/volunteer_model.dart';
import '../model/volunteer_task_model.dart';

abstract class VolunteerRepo {
  Future<void> submitVolunteer(VolunteerModel model);
  Future<String> getStatus(String userId);

  Stream<String> getStatusStream(String userId);

// --- new: needed for donor-side assignment ---

  /// Approved volunteers who are currently accepting tasks, best rated first.
  Stream<List<VolunteerModel>> watchAvailableApprovedVolunteers();

  /// The "pause / go offline" toggle - volunteer controls this from their profile.
  Future<void> setAcceptingTasks(String userId, bool value);

  /// Live view of this volunteer's own profile - used on Home for the
  /// availability toggle, name, and rating.
  Stream<VolunteerModel> watchProfile(String userId);

}