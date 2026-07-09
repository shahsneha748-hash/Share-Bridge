import '../model/create_donation_model.dart';

abstract class CreateDonationRepository {
  Future<bool> submitDonation(CreateDonationModel model);
}