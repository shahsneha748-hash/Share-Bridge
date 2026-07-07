class ProfileDisplayData {
  final String fullName;
  final String address;
  final String phone;
  final String bio;
  final String? profilePicture;
  final bool isVerified;
  final double rating;
  final int totalDonations;
  final int memberSinceYear;

  const ProfileDisplayData({
    required this.fullName,
    required this.address,
    required this.phone,
    required this.bio,
    required this.profilePicture,
    required this.isVerified,
    required this.rating,
    required this.totalDonations,
    required this.memberSinceYear,
  });

  ProfileDisplayData copyWith({String? profilePicture}) {
    return ProfileDisplayData(
      fullName: fullName,
      address: address,
      phone: phone,
      bio: bio,
      profilePicture: profilePicture ?? this.profilePicture,
      isVerified: isVerified,
      rating: rating,
      totalDonations: totalDonations,
      memberSinceYear: memberSinceYear,
    );
  }

  factory ProfileDisplayData.fromFirestoreMap(Map<String, dynamic> map) {
    int memberSinceYear = DateTime.now().year;
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw != null) {
      try {
        final toDate = createdAtRaw.toDate;
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
      bio: map['bio'] as String? ?? '',
      profilePicture: map['profilePicture'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      totalDonations: (map['totalDonations'] as num?)?.toInt() ?? 0,
      memberSinceYear: memberSinceYear,
    );
  }
}