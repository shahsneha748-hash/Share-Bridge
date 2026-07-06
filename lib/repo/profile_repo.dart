import 'package:sharebridge/model/profile_display_data.dart';

abstract class ProfileRepo {
  Future<ProfileDisplayData?> getProfile(String uid);
  Future<bool> updateProfilePicture(String uid, String imageUrl);

}