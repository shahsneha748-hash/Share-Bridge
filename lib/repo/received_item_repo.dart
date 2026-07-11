import '../model/volunteer_request_model.dart';

abstract class ReceivedItemsRepo {
  Stream<List<VolunteerRequestModel>> getReceivedItems(String receiverId);
}