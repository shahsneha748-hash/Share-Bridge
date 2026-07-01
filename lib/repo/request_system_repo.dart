import '../model/request_system_model.dart';

abstract class DonationRequestRepository {
  Stream<List<DonationRequestModel>> getRequests();
  Future<void> updateStatus(String requestId, String status);
}