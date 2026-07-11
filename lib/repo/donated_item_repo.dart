import '../model/volunteer_request_model.dart';

abstract class DonatedItemsRepo {
  Stream<List<VolunteerRequestModel>> getDonatedItems(String donorId);
}