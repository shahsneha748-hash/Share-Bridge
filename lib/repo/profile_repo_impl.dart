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
}