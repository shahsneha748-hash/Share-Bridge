import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sharebridge/model/profile_display_data.dart';
import 'package:sharebridge/repo/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final firestore = FirebaseFirestore.instance;

  @override
  Future<ProfileDisplayData?> getProfile(String uid) async {
    final doc = await firestore.collection("users").doc(uid).get();

    final data = doc.data();
    if (data == null) return null;

    // Get donation count
    final donationSnapshot = await firestore
        .collection("donations")
        .where("userId", isEqualTo: uid)
        .get();

    final totalDonations = donationSnapshot.docs.length;


    // Get reviews and calculate rating
    final reviewSnapshot = await firestore
        .collection("reviews")
        .where("targetUserId", isEqualTo: uid)
        .get();

    double rating = 0;

    if (reviewSnapshot.docs.isNotEmpty) {
      double totalRating = 0;

      for (var review in reviewSnapshot.docs) {
        totalRating += (review.data()['rating'] ?? 0).toDouble();
      }

      rating = totalRating / reviewSnapshot.docs.length;
    }


    // Add calculated values
    data['totalDonations'] = totalDonations;
    data['rating'] = rating;


    return ProfileDisplayData.fromFirestoreMap(data);
  }

  @override
  Future<bool> updateProfilePicture(String uid, String imageUrl) async {
    try {
      await firestore.collection("users").doc(uid).update({
        'profilePicture': imageUrl,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}