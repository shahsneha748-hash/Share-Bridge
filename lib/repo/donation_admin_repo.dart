abstract class DonationAdminRepo {
  Future<List<Map<String, dynamic>>> fetchDonations();
  Future<void> removeDonation(String donationId);
}