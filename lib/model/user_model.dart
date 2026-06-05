class UserModel {               // UserModel is the blueprint of what gets stored/retrieved from the database.
  final String id;              // unique identifier (UUID or Firebase UID)
  final String fullName;        // user's name
  final String email;           // login credential
  final String phone;           // contact number
  final String address;         // optional profile info
  final String role;            // "user", "donor", "receiver", "volunteer", "admin".          Note: A single user can act as both donor and receiver depending on context.
  final String? profilePicture; // optional image URL
  final bool isVerified;        // for trust/accountability
  final DateTime createdAt;     // when account was created
  final DateTime updatedAt;     // last profile update
  final double rating;      // average rating across feedback (trust score for all roles). Eg: Donor profile: “Bunny — Verified ✅ — Rating: 4.7            Another eg: Volunteer profile: “Julie — Rating: 4.9                Another eg: Receiver profile: "Alisa — Rating: 4.2
  final int totalDonations; // donor/volunteer impact metric. Eg: Donor profile: “Bunny — Verified ✅ — Rating: 4.7 — Total Donations: 35”.     Another eg: Volunteer profile: “Julie — Rating: 4.9 — Deliveries: 20” (could reuse the same field if you extend logic).       Another eg: Receiver profile: "Alisa — Rating: 4.2 — Total Donations: 0”


  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    this.profilePicture,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.rating,
    required this.totalDonations,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'fullName': this.fullName,
      'email': this.email,
      'phone': this.phone,
      'address': this.address,
      'role': this.role,
      'profilePicture': this.profilePicture,
      'isVerified': this.isVerified,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
      'rating': this.rating,
      'totalDonations': this.totalDonations,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String,
      role: map['role'] as String,
      profilePicture: map['profilePicture'] as String,
      isVerified: map['isVerified'] as bool,
      createdAt: map['createdAt'] as DateTime,
      updatedAt: map['updatedAt'] as DateTime,
      rating: map['rating'] as double,
      totalDonations: map['totalDonations'] as int,
    );
  }
}