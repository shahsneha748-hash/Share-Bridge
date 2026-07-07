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