import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {               // UserModel is the blueprint of what gets stored/retrieved from the database.
  final String uid;              // unique identifier (UUID or Firebase UID)
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
    required this.uid,
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
      'id': this.uid,
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
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? 'Unknown User',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      role: map['role'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      isVerified: map['isVerified'] ?? false,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
      totalDonations: (map['totalDonations'] is int) ? map['totalDonations'] : 0,
    );
  }
}