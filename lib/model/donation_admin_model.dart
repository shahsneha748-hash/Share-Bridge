enum DonationCategory { food, clothes, stationery, others }
enum DonationStatus { available, taken }

class AdminDonation {
  final String id;
  final String title;
  final String donorName;
  final String donorInitials;
  final DonationCategory category;
  DonationStatus status;
  final String location;
  final String postedTime;

  AdminDonation({
    required this.id,
    required this.title,
    required this.donorName,
    required this.donorInitials,
    required this.category,
    required this.status,
    required this.location,
    required this.postedTime,
  });

  String get categoryLabel {
    switch (category) {
      case DonationCategory.food:       return 'Food';
      case DonationCategory.clothes:    return 'Clothes';
      case DonationCategory.stationery: return 'Stationery';
      case DonationCategory.others:     return 'Others';
    }
  }

  String get statusLabel {
    switch (status) {
      case DonationStatus.available: return 'Available';
      case DonationStatus.taken:     return 'Taken';
    }
  }
}