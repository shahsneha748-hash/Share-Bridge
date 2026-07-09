import '../model/volunteer_request_model.dart';


abstract class VolunteerRequestRepo {


  Future<void> createRequest(
      VolunteerRequestModel request
      );


  Stream<List<VolunteerRequestModel>>
  getVolunteerRequests();


  Future<void> updateRequestStatus(
      String requestId,
      String status,
      );


}