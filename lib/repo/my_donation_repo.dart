import 'package:sharebridge/model/donation_record.dart';

abstract class MyDonationsRepo {
  Stream<List<DonationRecord>> getDonationsForUser(String userId);
}