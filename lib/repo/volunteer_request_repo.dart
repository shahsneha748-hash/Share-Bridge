import '../model/volunteer_request_model.dart';

abstract class VolunteerRequestRepo {
  Future<void> createRequest(VolunteerRequestModel request);

  Stream<List<VolunteerRequestModel>> getVolunteerRequests();

  Future<bool> acceptRequest(String requestId, String volunteerId);

  Future<void> rejectRequest(String requestId, String volunteerId);

  Future<void> updateRequestStatus(String requestId, String status);

  Future<void> confirmDelivery(String requestId);


}