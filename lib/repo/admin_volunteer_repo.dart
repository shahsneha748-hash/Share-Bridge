import '../model/admin_volunteer_model.dart';

abstract class AdminVolunteerRepo {
  Future<List<AdminVolunteerModel>> fetchVolunteers();
  Future<void> updateVolunteerStatus(String volunteerId, String status);
}