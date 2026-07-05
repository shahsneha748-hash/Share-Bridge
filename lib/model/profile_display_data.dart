class ProfileDisplayData {
  final String fullName;
  final String address;
  final String phone;
  final String? profilePicture;
  final bool isVerified;
  final double rating;
  final int totalDonations;
  final int memberSinceYear;

  const ProfileDisplayData({
    required this.fullName,
    required this.address,
    required this.phone,
    required this.profilePicture,
    required this.isVerified,
    required this.rating,
    required this.totalDonations,
    required this.memberSinceYear,
  });

  factory ProfileDisplayData.fromFirestoreMap(Map<String, dynamic> map) {
    int memberSinceYear = DateTime.now().year;
    final createdAtRaw = map['createdAt'];
    // Handles both Firestore Timestamp and plain DateTime safely,
    // without ever touching UserModel.fromMap().
    if (createdAtRaw != null) {
      try {
        final toDate = createdAtRaw.toDate; // Timestamp has this method
        memberSinceYear = (toDate() as DateTime).year;
      } catch (_) {
        if (createdAtRaw is DateTime) {
          memberSinceYear = createdAtRaw.year;
        }
      }
    }

    return ProfileDisplayData(
      fullName: map['fullName'] as String? ?? 'User',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      profilePicture: map['profilePicture'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      totalDonations: (map['totalDonations'] as num?)?.toInt() ?? 0,
      memberSinceYear: memberSinceYear,
    );
  }
}