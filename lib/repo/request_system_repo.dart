import '../model/create_donation_model.dart';
import '../model/request_system_model.dart';

abstract class RequestSystemRepo {
  Stream<List<RequestSystemModel>> getRequests();
  Future<void> updateStatus(String requestId, String status);
  Future<void> createRequest(RequestSystemModel request);
  Future<CreateDonationModel?> getDonationById(String id);
}